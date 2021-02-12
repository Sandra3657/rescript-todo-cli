/*
Sample JS implementation of Todo CLI that you can attempt to port:
https://gist.github.com/jasim/99c7b54431c64c0502cfe6f677512a87
*/

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

// Js.log("Hello! today is " ++ getToday())

// if existsSync("todo.txt") {
//   Js.log("Todo file exists.")
// } else {
//   writeFileSync("todo.txt", "This is todo!" ++ eol, {encoding: encoding, flag: "w"})
//   Js.log("Todo file created.")
// }

let pending_todos_file: string = "todo.txt"
let completed_todos_file = "done.txt"

let help_string = `Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`

@bs.module("process")
external argv: array<string> = "argv"

let argv = argv
let args = Js.Array.sliceFrom(2, argv)

let isEmpty = x => {
  if Belt.Array.length(x) == 0 {
    true
  } else {
    false
  }
}

let cmdHelp = () => {
  Js.log(help_string)
}

let getIndex = x =>
  switch x {
  | None => 0
  | Some(x) => x
  }

let cmdLs = () => {
  let todos = readFileSync(pending_todos_file, {encoding: "utf8", flag: "r"})
  if Js.String.length(todos) == 0 {
    Js.log("There are no pending todos!")
  } else {
    let todos: array<string> = Js.String.split("\n", todos)
    let () = Belt.Array.reverseInPlace(todos)
    let length = todos->Belt.Array.length
    let string = (todo, index) => `[${Belt.Int.toString(length - index)}] ${todo}`
    let todos = Js.Array.mapi(string, todos)
    Js.log(todos)
  }
}

let option = args => {
  if isEmpty(args) {
    // Js.log(help_string)
    cmdHelp()
  } else {
    let args = Belt.Array.map(args, x => x->Js.String.trim->Js.String.toLowerCase)
    let command = Js.Array.shift(args)
    let command = switch command {
    | None => "none"
    | Some(x) => x
    }
    switch command {
    | "help" => cmdHelp()
    | "ls" => cmdLs()
    | _ => cmdHelp()
    }
  }
}

let _ = option(args)

// Js.log(option(args))
// Js.log(option(args))
// case 'help':
//       cmdHelp()
//       break;
//     case 'ls':
//       cmdLs()
//       break
//     case 'add':
//       cmdAddTodo(arg)
//       break
//     case 'del':
//       cmdDelTodo(arg)
//       break
//     case 'done':
//       cmdMarkDone(arg)
//       break
//     case 'report':
//       cmdReport()
//       break
//     default:
//       cmdHelp()
