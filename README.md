# as3-async
Asynchronous AS3 tasks are intended to simplify event flow usually in loading or animation sequences.
 1. Asynchronous tasks are very close to [JS Promises](https://www.promisejs.org/) however they are written in more object oriented style.
 2. There are wrappers for commonly used Flash API.
 3. No events are created and dispatched, we use direct callbacks because they are more fast.
 4. Error handling is provided.
 5. Synchronous functions can be used as asynchronous tasks.

## Getting started

### Define asynchronous sequence
Asynchronous sequence is defined using fluent interface where each method accepts `ITask` or `Function`. For example the following code defines a sequence that loads "some.swf", then "some.xml" and calls the callback function when all tasks are complete:
```actionscript
async(new LoaderTask("some.swf"))
.then(new URLLoaderTask("some.xml"))
.then(function():void {trace("complete");});
```

### Run asynchronous sequence
Once the sequence is defined it should be started or stored in a variable:
```actionscript
var s:IAsync = async(new LoaderTask("some.swf"))
  .then(new URLLoaderTask("some.xml"))
  .then(function():void {trace("complete");});
s.await();
```
> Note that the sequence can run only once. It can not be started again if complete or canceled.

### Passing arguments
Each task in the sequence has input and output parameters (like single argument and return value in a function). The output of previous task is input of the next task and so on. The first argument in the sequence can be passed to `await` method. The following example uses functions to display arguments, however you can define an asynchronous task that will be using arguments the same way:
```actionscript
async(function(arg:String):void {trace(arg);}) // start-sequence
.then(new LoaderTask("some.swf"))
.then(function(loader:Loader):void {trace(loader.content);}); // [object MovieClip]
.then(new URLLoaderTask("some.xml"))
.then(function(loader:URLLoader):void {trace(loader.data);}); // <some-xml/>
.await("start-sequence");
```
Actually you can pass your arguments directly to `async` and `then` method if the arguments are known when the sequence is defined:
```actionscript
async("start-sequence")
.then(function(arg:String):void {trace(arg);}) // start-sequence
.then(new LoaderTask("some.swf"))
.then("continue-sequence")
.then(function(arg:String):void {trace(arg);}) // continue-sequence
.then(new URLLoaderTask("some.xml"))
.await();
```
Notice that `Error` and `ErrorEvent` are considered as errors and they are "thrown" (see **Handling errors** section). For example here `URLLoaderTask` is never executed:
```actionscript
async(new LoaderTask("some.swf"))
.then(new Error())
.then(new URLLoaderTask("some.xml"))
.await();
```

### Handling errors
The task can complete successfully or not (like fulfill and reject in promises). If it is not successful it "throws" an error and no further tasks are executed until an error handler is found. The error handler is a task passed to method `except`. For example single error handler for all tasks (note that `URLLoaderTask` is not executed if `URLLoaderTask` fails):
```actionscript
async(new LoaderTask("some.swf"))
.then(new URLLoaderTask("some.xml"))
.except(function(error:*):void {trace(error);}); // IOErrorEvent or SecurityErrorEvent
.then(function():void {trace("complete");}); // complete
.await();
```
Also you can define many error handlers for each of tasks (in that case `URLLoaderTask` is executed even if `URLLoaderTask` fails):
```actionscript
async(new LoaderTask("some.swf"))
.except(function(error:*):void {trace(error);}); // IOErrorEvent or SecurityErrorEvent
.then(new URLLoaderTask("some.xml"))
.except(function(error:*):void {trace(error);}); // IOErrorEvent or SecurityErrorEvent
.then(function():void {trace("complete");}); // complete
.await();
```
Errors thrown by functions are also handled the same way:
```actionscript
async(function():void {throw new Error();})
.except(function(error:*):void {trace(error);}); // Error
.then(function():void {trace("complete");}); // complete
.await();
```
Error handler can be any task, so for example you can execute `URLLoaderTask` only if `LoaderTask` fails:
```actionscript
async(new LoaderTask("some.swf"))
.except(new URLLoaderTask("some.xml"));
.then(function():void {trace("complete");});
.await();
```

### Branching
When you need a task to be executed only if the previous tasks are successful you can use branching. The following example loads one or another xml depending on success of `URLLoaderTask`:
```actionscript
async(new LoaderTask("some.swf"))
.then(new URLLoaderTask("success.xml"),
      new URLLoaderTask("failure.xml"))
.then(function():void {trace("complete");}); // complete
.await();
```
Branching and error handling can be combined in any way. For example here we can handle errors of whatever `URLLoaderTask` is executed:
```actionscript
async(new LoaderTask("some.swf"))
.then(new URLLoaderTask("success.xml"),
      new URLLoaderTask("failure.xml"))
.except(function(error:*):void {trace(error);}); // IOErrorEvent or SecurityErrorEvent
.then(function():void {trace("complete");}); // complete
.await();
```

### Canceling execution
Execution of asynchronous sequence can be interrupted at any moment. But you need to keep a reference to the asynchronous sequence to do that. For example canceling loading in 100 ms regardless of which file exactly is being loaded at the moment:
```actionscript
var s:IAsync = async(new LoaderTask("some.swf"))
.then(new URLLoaderTask("some.xml"));
s.await();
setTimeout(function() {s.cancel();}, 100);
```

### Adding new tasks
When your sequence is already running you can still add new tasks to it. Those new tasks will be executed as usual:
```actionscript
var s:IAsync = async(new LoaderTask("some.swf"))
s.await();
s.then(new URLLoaderTask("some.xml"));
```
> Be careful with this feature. First of all don't add error handlers to the running sequence because you can get error before adding the handler. Also call `await` after adding new tasks to make sure the sequence continues if it is already complete.

This feature can be usefull when implementing asynchronous queue that executes tasks one after another:
```actionscript
public class Queue {
  private var _async:IAsync = async();
  public function add(task:Object, onComplete:Function, onError:Function):void {
    _async
      .then(async(task).then(onComplete, onError))
      .await();
  }
}
```

## Flash API wrappers

### Loader tasks
- `LoaderTask(source:*, context:LoaderContext = null)` uses [Loader](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Loader.html) object to load a flash movie from the given url, `URLRequest`, `ByteArray` object or class; returns `Loader` object; throws `IOErrorEvent`, `SecurityErrorEvent`.
- `URLLoaderTask(source:Object, format:String = "text")` uses [URLLoader](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/URLLoader.html) to load a file from the given url or `URLRequest`; returns `URLLoader` object; throws `IOErrorEvent`, `SecurityErrorEvent`.

### Timout tasks
- `TimeoutTask(milliseconds=0)` waits for the given number of milliseconds.
- `FramesTask(frames=0)` waits for the given number of frames.

### File reference tasks
The following tasks use [FileReference](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/FileReference.html) to browse, download or upload files:
- `BrowseFileTask(filters:Array = null)` returns `FileReference` with the selected file or throws `Event.CANCEL` if no file is selected.
- `DownloadFileTask(source:Object, defaultFileName:String = null)` returns `FileReference` with the downloaded file or throws `Event.CANCEL`, `IOErrorEvent`, `SecurityErrorEvent`.
- `UploadFileTask(source:Object, dataFieldName:String = "Filedata")` gets `FileReference` as argument and uploads it to the given url, must be called after `BrowseFileTask`.
- `LoadFileTask()` gets `FileReference` as argument and loads file content, must be called after `BrowseFileTask`.

## Task definition
1. Subsequent `async`
2. Factory function
3. Extending `Task`
4. Implementing `ITask`
5. Promise style

## Asynchronous concurrence
