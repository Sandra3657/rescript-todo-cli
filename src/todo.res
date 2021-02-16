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

type cmd =
  | Help
  | Ls
  | Add(array<string>)
  | Delete(array<string>)
  | Done(array<string>)
  | Report

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
  let todos = readFile(pending_todos_file)
  if number < 1 || number > todos->Belt.Array.length {
    Js.log(`Error: todo #${number->Belt.Int.toString} does not exist. Nothing deleted.`)
  } else {
    let _ = Js.Array.spliceInPlace(~pos=number - 1, ~remove=1, ~add=[], todos)
    Js.log(`Deleted todo #${number->Belt.Int.toString}`)
    writeFileSync(
      pending_todos_file,
      Js.Array.joinWith("\n", todos),
      {encoding: encoding, flag: "w"},
    )
  }
}

let markTodo = number => {
  let todos = readFile(pending_todos_file)
  if number < 1 || number > todos->Belt.Array.length {
    Js.log(`Error: todo #${number->Belt.Int.toString} does not exist.`)
  } else {
    let completedTodo = Js.Array.spliceInPlace(~pos=number - 1, ~remove=1, ~add=[], todos)
    writeFileSync(
      pending_todos_file,
      Js.Array.joinWith("\n", todos),
      {encoding: encoding, flag: "w"},
    )
    appendFileSync(completed_todos_file, completedTodo[0] ++ eol, {encoding: encoding, flag: "a"})
    Js.log(`Marked todo #${number->Belt.Int.toString} as done.`)
  }
}

let cmdHelp = () => {
  Js.log(help_string)
}

let cmdLs = () => {
  let todos = readFile(pending_todos_file)
  if todos->Belt.Array.length == 0 {
    Js.log("There are no pending todos!")
  } else {
    let () = Belt.Array.reverseInPlace(todos)
    let length = todos->Belt.Array.length
    todos->Belt.Array.forEachWithIndex((index, todo) =>
      Js.log(`[${Belt.Int.toString(length - index)}] ${todo}`)
    )
  }
}

let cmdAddTodo = text => {
  if isEmpty(text) {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    Belt.Array.forEach(text, x => {
      appendFileSync(pending_todos_file, x ++ eol, {encoding: encoding, flag: "a"})
      Js.log(`Added todo: "${x}"`)
    })
  }
}

let cmdDelTodo = numbers => {
  if isEmpty(numbers) {
    Js.log("Error: Missing NUMBER for deleting todo.")
  } else {
    let numbers = numbers->Belt.Array.map(num => num->Belt.Int.fromString)
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
    let numbers = numbers->Belt.Array.map(num => num->Belt.Int.fromString)
    numbers->Belt.Array.forEach(num =>
      switch num {
      | None => Js.log("Error")
      | Some(x) => x->markTodo
      }
    )
  }
}

let cmdReport = () => {
  let pending = readFile(pending_todos_file)->Belt.Array.length
  let completed = readFile(completed_todos_file)->Belt.Array.length
  Js.log(
    `${getToday()} Pending : ${pending->Belt.Int.toString} Completed : ${completed->Belt.Int.toString}`,
  )
}

let option = args => {
  if isEmpty(args) {
    cmdHelp()
  } else {
    let args = Belt.Array.map(args, x => x->Js.String.trim->Js.String.toLowerCase)
    let command = Js.Array.shift(args)
    let command = switch command {
    | None => "none"
    | Some(x) => x
    }
    let command = switch command {
    | "ls" => Ls
    | "add" => Add(args)
    | "del" => Delete(args)
    | "done" => Done(args)
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
}

let _ = option(args)
