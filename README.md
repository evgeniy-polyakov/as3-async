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
setTimeout(function():void {s.cancel();}, 100);
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
### Nested `async`
`async` function itself returns a task so you can simply pass one `async` into another. This is useful in case of complex error handling and branching. For example we can load two files sequentially if the main task fails:
```actionscript
async(new LoaderTask("some.swf"))
.except(async(new URLLoaderTask("file1.xml"))
        .then(new URLLoaderTask("file2.xml")))
.then(function():void {trace("complete");});
.await();
```

###Factory function
Factory function allows to define a task based on result of the previous task. The function should return `ITask`. For example load xml or json files based on config value:
```actionscript
async(new URLLoaderTask("config.txt"))
.then(function(loader:URLLoader):ITask {
  if (loader.data == "load-xml") {
    return async(new URLLoaderTask("file1.xml"))
           .then(new URLLoaderTask("file2.xml"));
  } else {
    return new URLLoaderTask("file.json");
  }
})
.then(function():void {trace("complete");});
.await();
```

###Promise style
Using factory function you can keep an instance of `Task` in closure and return or throw depending of the result of your asynchronous method. The following example waits for 100 ms and returns or throws based on config value:
```actionscript
async(new URLLoaderTask("config.txt"))
.then(function(loader:URLLoader):ITask {
  var task:Task = new Task();
  if (loader.data == "ok") {
    setTimeout(function():void {task.onReturn("Success");}, 100);
  } else {
    setTimeout(function():void {task.onThrow(new Error());}, 100);
  }
  return task;
})
.except(function(error:*):void {trace(error);}) // Error
.then(function(value:*):void {trace(value);}); // Success
.await();
```

###Extending `Task`
If you want to implement completely custom task it could be done by extending `Task` class. Then you will be able to use that task in a sequence, await and cancel it like any other task. The following example defines a task that waits for 100 ms and returns or throws based on the given arguments:
```actionscript
public class MyTask extends Task {
  private var _timeoutId;
  override public function onAwait():void {
    if (args == "ok") {
      _timeoutId = setTimeout(function():void {onReturn("Success");}, 100);
    } else {
      _timeoutId = setTimeout(function():void {onThrow(new Error());}, 100);
    }
  }
  override public function onCancel():void {
    clearTimeout(_timeoutId);
  }
}
```

###Implementing `ITask`
If you want to implement a custom task that extends your base class you can implement `ITask` interface and use inner `Task` object. The following example defines a task that waits for 100 ms and returns or throws based on the given arguments:
```actionscript
public class MyTask extends MyBaseClass implements ITask {
  private var _innerTask:Task = new Task();
  private var _timeoutId;
  public function await(args:Object = null, result:IResult = null):void {
    _innerTask.await(args, result);
    if (args == "ok") {
      _timeoutId = setTimeout(function():void {_innerTask.onReturn("Success", this);}, 100);
    } else {
      _timeoutId = setTimeout(function():void {_innerTask.onThrow(new Error(), this);}, 100);
    }
  }
  public function cancel():void {
    _innerTask.cancel();
    clearTimeout(_timeoutId);
  }
}
```

## Asynchronous concurrence
