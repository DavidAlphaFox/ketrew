(**************************************************************************)
(*  Copyright 2014, Sebastien Mondet <seb@mondet.org>                     *)
(*                                                                        *)
(*  Licensed under the Apache License, Version 2.0 (the "License");       *)
(*  you may not use this file except in compliance with the License.      *)
(*  You may obtain a copy of the License at                               *)
(*                                                                        *)
(*      http://www.apache.org/licenses/LICENSE-2.0                        *)
(*                                                                        *)
(*  Unless required by applicable law or agreed to in writing, software   *)
(*  distributed under the License is distributed on an "AS IS" BASIS,     *)
(*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or       *)
(*  implied.  See the License for the specific language governing         *)
(*  permissions and limitations under the License.                        *)
(**************************************************************************)

(** Command line interface to the engine. *)

open Ketrew_pervasives

val run_client :
  ?plugins:(string * (module Ketrew_long_running.LONG_RUNNING)) list ->
  ?argv:string array ->
  ?override_configuration:Ketrew_configuration.t ->
  unit ->
  [ `Never_returns ]
(** The “main” function for the client-side, it will [exit n] with [n = 0] if
    succeed or [n > 0] if fails. *)

val run_server :
  ?plugins:(string * (module Ketrew_long_running.LONG_RUNNING)) list ->
  ?argv:string array ->
  ?override_configuration:Ketrew_configuration.t ->
  unit ->
  [ `Never_returns ]
(** The “main” function for the server-side, it will [exit n] with [n = 0] if
    succeed or [n > 0] if fails. *)

