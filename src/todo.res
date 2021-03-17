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

@val @scope("process") external argv: array<string> = "argv"

let encoding = "utf8"
let pendingTodosFile: string = "todo.txt"
let completedTodosFile = "done.txt"

let help_string = `Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`

type cmd =
  | Help
  | Ls
  | Add(array<string>)
  | Delete(array<option<int>>)
  | Done(array<option<int>>)
  | Report

let isEmpty = x => {
  if Belt.Array.length(x) == 0 {
    true
  } else {
    false
  }
}

let convertToInt = x => {
  x->Belt.Array.map(x => x->Belt.Int.fromString)
}

let readFile = file => {
  if existsSync(file) {
    let text = readFileSync(file, {encoding: encoding, flag: "r"})->Js.String.trim
    if text->Js.String.length != 0 {
      let lines = Js.String.split(eol, text)
      lines
    } else {
      []
    }
  } else {
    []
  }
}

let delTodo = number => {
  let todos = readFile(pendingTodosFile)
  if number < 1 || number > todos->Belt.Array.length {
    Js.log(`Error: todo #${number->Belt.Int.toString} does not exist. Nothing deleted.`)
  } else {
    let _ = Js.Array.spliceInPlace(~pos=number - 1, ~remove=1, ~add=[], todos)
    Js.log(`Deleted todo #${number->Belt.Int.toString}`)
    writeFileSync(pendingTodosFile, Js.Array.joinWith("\n", todos), {encoding: encoding, flag: "w"})
  }
}

let markTodo = number => {
  let todos = readFile(pendingTodosFile)
  if number < 1 || number > todos->Belt.Array.length {
    Js.log(`Error: todo #${number->Belt.Int.toString} does not exist.`)
  } else {
    let completedTodo = Js.Array.spliceInPlace(~pos=number - 1, ~remove=1, ~add=[], todos)
    writeFileSync(pendingTodosFile, Js.Array.joinWith("\n", todos), {encoding: encoding, flag: "w"})
    appendFileSync(completedTodosFile, completedTodo[0] ++ eol, {encoding: encoding, flag: "a"})
    Js.log(`Marked todo #${number->Belt.Int.toString} as done.`)
  }
}

let cmdHelp = () => {
  Js.log(help_string)
}

let cmdLs = () => {
  let todos = readFile(pendingTodosFile)
  if todos->Belt.Array.length == 0 {
    Js.log("There are no pending todos!")
  } else {
    todos
    ->Belt.Array.mapWithIndex((i, x) => `[${(i + 1)->Belt.Int.toString}] ${x}`)
    ->Belt.Array.reverse
    ->Belt.Array.reduce(``, (acc, x) => acc ++ x ++ `\n`)
    ->Js.log
  }
}

let cmdAddTodo = text => {
  if isEmpty(text) {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    Belt.Array.forEach(text, x => {
      appendFileSync(pendingTodosFile, x ++ eol, {encoding: encoding, flag: "a"})
      Js.log(`Added todo: "${x}"`)
    })
  }
}

let cmdDelTodo = numbers => {
  if isEmpty(numbers) {
    Js.log("Error: Missing NUMBER for deleting todo.")
  } else {
    numbers->Belt.Array.forEach(num =>
      switch num {
      | None => Js.log("Error")
      | Some(x) => x->delTodo
      }
    )
  }
}

let cmdMarkDone = numbers => {
  if isEmpty(numbers) {
    Js.log(`Error: Missing NUMBER for marking todo as done.`)
  } else {
    numbers->Belt.Array.forEach(num =>
      switch num {
      | None => Js.log("Error")
      | Some(x) => x->markTodo
      }
    )
  }
}

let cmdReport = () => {
  let pending = readFile(pendingTodosFile)->Belt.Array.length
  let completed = readFile(completedTodosFile)->Belt.Array.length
  Js.log(
    `${getToday()} Pending : ${pending->Belt.Int.toString} Completed : ${completed->Belt.Int.toString}`,
  )
}

let argv = argv
let command = argv->Belt.Array.get(2)
let args = Js.Array.removeFromInPlace(argv, ~pos=3)

let option = (command, args) => {
  let command = switch command {
  | None => "help"
  | Some(x) => x
  }

  let command = switch command {
  | "ls" => Ls
  | "add" => Add(args)
  | "del" => Delete(args->convertToInt)
  | "done" => Done(args->convertToInt)
  | "report" => Report
  | _ => Help
  }

  switch command {
  | Help => cmdHelp()
  | Ls => cmdLs()
  | Add(args) => cmdAddTodo(args)
  | Delete(args) => cmdDelTodo(args)
  | Done(args) => cmdMarkDone(args)
  | Report => cmdReport()
  }
}

let _ = option(command, args)
