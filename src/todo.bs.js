// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Os = require("os");
var Curry = require("bs-platform/lib/js/curry.js");
var Process = require("process");
var Belt_Int = require("bs-platform/lib/js/belt_Int.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_array = require("bs-platform/lib/js/caml_array.js");

var getToday = (function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
});

var encoding = "utf8";

var pending_todos_file = "todo.txt";

var completed_todos_file = "done.txt";

var help_string = "Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics";

var argv = Process.argv;

var args = argv.slice(2);

function isEmpty(x) {
  return x.length === 0;
}

function readFile(file) {
  if (!Fs.existsSync(file)) {
    return [];
  }
  var text = Fs.readFileSync(file, {
          encoding: encoding,
          flag: "r"
        }).trim();
  if (text.length !== 0) {
    return text.split(Os.EOL);
  } else {
    return [];
  }
}

function delTodo(number) {
  var todos = readFile(pending_todos_file);
  if (number < 1 || number > todos.length) {
    console.log("Error: todo #" + String(number) + " does not exist. Nothing deleted.");
  } else {
    todos.splice(number - 1 | 0, 1);
    console.log("Deleted todo #" + String(number));
    Fs.writeFileSync(pending_todos_file, todos.join("\n"), {
          encoding: encoding,
          flag: "w"
        });
  }
  
}

function markTodo(number) {
  var todos = readFile(pending_todos_file);
  if (number < 1 || number > todos.length) {
    console.log("Error: todo #" + String(number) + " does not exist.");
    return ;
  }
  var completedTodo = todos.splice(number - 1 | 0, 1);
  Fs.writeFileSync(pending_todos_file, todos.join("\n"), {
        encoding: encoding,
        flag: "w"
      });
  Fs.appendFileSync(completed_todos_file, Caml_array.get(completedTodo, 0) + Os.EOL, {
        encoding: encoding,
        flag: "a"
      });
  console.log("Marked todo #" + String(number) + " as done.");
  
}

function cmdHelp(param) {
  console.log(help_string);
  
}

function cmdLs(param) {
  var todos = readFile(pending_todos_file);
  if (todos.length === 0) {
    console.log("There are no pending todos!");
    return ;
  }
  Belt_Array.reverseInPlace(todos);
  var length = todos.length;
  return Belt_Array.forEachWithIndex(todos, (function (index, todo) {
                console.log("[" + String(length - index | 0) + "] " + todo);
                
              }));
}

function cmdAddTodo(text) {
  if (text.length === 0) {
    console.log("Error: Missing todo string. Nothing added!");
    return ;
  } else {
    return Belt_Array.forEach(text, (function (x) {
                  Fs.appendFileSync(pending_todos_file, x + Os.EOL, {
                        encoding: encoding,
                        flag: "a"
                      });
                  console.log("Added todo: \"" + x + "\"");
                  
                }));
  }
}

function cmdDelTodo(numbers) {
  if (numbers.length === 0) {
    console.log("Error: Missing NUMBER for deleting todo.");
    return ;
  }
  var numbers$1 = Belt_Array.map(numbers, Belt_Int.fromString);
  return Belt_Array.forEach(numbers$1, (function (num) {
                if (num !== undefined) {
                  return delTodo(num);
                } else {
                  console.log("Error");
                  return ;
                }
              }));
}

function cmdMarkDone(numbers) {
  if (numbers.length === 0) {
    console.log("Error: Missing NUMBER for marking todo as done.");
    return ;
  }
  var numbers$1 = Belt_Array.map(numbers, Belt_Int.fromString);
  return Belt_Array.forEach(numbers$1, (function (num) {
                if (num !== undefined) {
                  return markTodo(num);
                } else {
                  console.log("Error");
                  return ;
                }
              }));
}

function cmdReport(param) {
  var pending = readFile(pending_todos_file).length;
  var completed = readFile(completed_todos_file).length;
  console.log(Curry._1(getToday, undefined) + " Pending : " + String(pending) + " Completed : " + String(completed));
  
}

function option(args) {
  if (args.length === 0) {
    console.log(help_string);
    return ;
  }
  var args$1 = Belt_Array.map(args, (function (x) {
          return x.trim().toLowerCase();
        }));
  var command = args$1.shift();
  var command$1 = command !== undefined ? command : "none";
  var command$2;
  switch (command$1) {
    case "add" :
        command$2 = {
          TAG: /* Add */0,
          _0: args$1
        };
        break;
    case "del" :
        command$2 = {
          TAG: /* Delete */1,
          _0: args$1
        };
        break;
    case "done" :
        command$2 = {
          TAG: /* Done */2,
          _0: args$1
        };
        break;
    case "ls" :
        command$2 = /* Ls */1;
        break;
    case "report" :
        command$2 = /* Report */2;
        break;
    default:
      command$2 = /* Help */0;
  }
  if (typeof command$2 === "number") {
    switch (command$2) {
      case /* Help */0 :
          console.log(help_string);
          return ;
      case /* Ls */1 :
          return cmdLs(undefined);
      case /* Report */2 :
          return cmdReport(undefined);
      
    }
  } else {
    switch (command$2.TAG | 0) {
      case /* Add */0 :
          return cmdAddTodo(command$2._0);
      case /* Delete */1 :
          return cmdDelTodo(command$2._0);
      case /* Done */2 :
          return cmdMarkDone(command$2._0);
      
    }
  }
}

option(args);

exports.getToday = getToday;
exports.encoding = encoding;
exports.pending_todos_file = pending_todos_file;
exports.completed_todos_file = completed_todos_file;
exports.help_string = help_string;
exports.argv = argv;
exports.args = args;
exports.isEmpty = isEmpty;
exports.readFile = readFile;
exports.delTodo = delTodo;
exports.markTodo = markTodo;
exports.cmdHelp = cmdHelp;
exports.cmdLs = cmdLs;
exports.cmdAddTodo = cmdAddTodo;
exports.cmdDelTodo = cmdDelTodo;
exports.cmdMarkDone = cmdMarkDone;
exports.cmdReport = cmdReport;
exports.option = option;
/* argv Not a pure module */
