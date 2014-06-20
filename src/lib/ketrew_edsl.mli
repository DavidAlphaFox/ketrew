(** Easy interface to the library {b for end users}. *)
(**
  This is a more hopefully stable EDSL/API to make workflows and
  deal with the system.

  Many functions may raise exceptions when called on improperly, but this
  should happen while building the workflow, not after it starts running. *)


(** {3 Hosts} *)

type host = Ketrew_host.t
(** Alias for the host type. *)

val parse_host : string -> host
(** See {!Ketrew_host.of_uri}. *)

val host_cmdliner_term :
  ?doc:string -> 
  [ `Required of int | `Flag of string list ] ->
  Ketrew_host.t Cmdliner.Term.t
(** Cmdliner term which creates a host argument or flag.
    [`Required n] will be an anonymous argument at position [n]; 
    [`Flag ["option-name"; "O"]] will create an optional
    flag ["--option-name"] (aliased to ["-O"]) whose default value is
    the host ["/tmp/"] (i.e. Localhost with ["/tmp"] as “playground”).
    *)

(** {3 Build Programs} *)

(** Build “things to run”. *)
module Program: sig

  type t = Ketrew_program.t
  (** Something to run {i is} a {!Ketrew_program.t}. *)

  val sh: string -> t
  (** Create a program that runs a shell command. *)

  val shf: ('a, unit, string, t) format4 -> 'a
  (** Printf-like function to create shell commands. *)

  val (&&): t -> t -> t
  (** [a && b] is a program than runs [a] then [b] iff [a] succeeded. *)

  val exec: string list -> t
  (** Create a program that run in [Unix.exec] mode (i.e. does not need shell
      escaping). *)

end

(** {3 Artifacts} *)

(** Wrapper for {!Ketrew_artifact.t} and {!Ketrew_artifact.Type.t}. *)
class type user_artifact = object

  method path : string
  (** Return the path of the artifact if the artifact is a volume containing
      a single file or directory. *)

  method exists : Ketrew_target.Condition.t
  (** Get “is-ready” condition (for the [~ready_when] argument of {!target}. *)

end

val file: ?host:Ketrew_host.t -> string -> user_artifact
(** Create a volume containing one file. *)

val unit : user_artifact
(** The artifact that is “never ready” (i.e. the target associated will always
    be (re-)run if activated). *)

(** {3 Targets} *)

(** Wrapper around {!Ketrew_target.t}. *)
class type user_target =
  object

    method activate : unit
    (** Activate the target. *)

    method name : string
    (** Get the name of the target *)

    method metadata: Ketrew_artifact.value
    (** The metadata that has been set for the target. *)

    (**/**)
    method is_active: bool
    method id: Ketrew_pervasives.Unique_id.t
    method render: Ketrew_target.t
    method dependencies: user_target list
    (**/**)
  end

val target :
  ?active:bool ->
  ?dependencies:user_target list ->
  ?make:Ketrew_target.build_process ->
  ?ready_when:Ketrew_target.Condition.t ->
  ?metadata:Ketrew_artifact.value ->
  string -> user_target
(** Create a new target. *)

val active :
  ?dependencies:user_target list ->
  ?make:Ketrew_target.build_process ->
  ?ready_when:Ketrew_target.Condition.t ->
  ?metadata:Ketrew_artifact.value ->
  string -> user_target
(** Create a new target but with [~active:true]. *)

val nohup_setsid :
  host:Ketrew_host.t -> Program.t -> Ketrew_target.build_process
(** Create a nohup_setsid build process. *)

val direct_execution :
  ?host:Ketrew_host.t -> Program.t -> Ketrew_target.build_process
(** Create a direct process (not “long-running”). *)

val direct_shell_command :
  ?host:Ketrew_host.t -> string -> Ketrew_target.build_process
(** Shortcut for [direct_execution ?host Program.(sh cmd)]. *)

val get_output :
  ?host:Ketrew_host.t -> Program.t -> Ketrew_target.build_process
(** Create a direct process (not “long-running”) that stores the output (i.e.
    [stdout]) of the program. *)

val lsf :
  ?host:Ketrew_host.t ->
  ?queue:string ->
  ?name:string ->
  ?wall_limit:string ->
  ?processors:[ `Min of int | `Min_max of int * int ] ->
  Program.t -> Ketrew_target.build_process
(** Create an “LSF” build process. *)

(** {3 Workflows} *)

val run:
  ?plugins:(string * (module Ketrew_long_running.LONG_RUNNING)) list ->
  ?override_configuration:Ketrew_configuration.t ->
  user_target ->
  unit
(** Activate [user_target] (the next time Ketrew runs a step, the target will
    started/run. *)


