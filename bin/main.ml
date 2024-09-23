open Eio

exception Timeout

let timeout = 2.0
let compute = 1.0

let compute () =
  Eio_main.run @@ fun _env ->
  Switch.run @@ fun sw ->
  Fiber.fork_daemon ~sw (fun () ->
      Eio_unix.sleep timeout;
      raise Timeout);
  let promise =
    Fiber.fork_promise ~sw (fun () ->
        Eio_unix.sleep compute;
        42)
  in
  Promise.await promise

let () =
  try
    let result = compute () in
    match result with Error _ -> () | Ok i -> traceln "result: %d" i
  with Timeout -> traceln "Timeout"
