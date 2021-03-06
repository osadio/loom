%%------------------------------------------------------------------------------
%% Copyright 2014 FlowForwarding.org
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%-----------------------------------------------------------------------------

%% @author Erlang Solutions Ltd. <openflow@erlang-solutions.com>
%% @copyright 2014 FlowForwarding.org

-module(net_observer_ofsh).
-include("include/net_observer_logger.hrl").
-include_lib("ofs_handler/include/ofs_handler.hrl").
-include_lib("of_protocol/include/of_protocol.hrl").

-export([
    init/7,
    connect/8,
    disconnect/1,
    failover/1,
    handle_message/2,
    handle_error/2,
    terminate/1
]).

-define(OFS_STATE, net_observer_ofs_state).
-record(?OFS_STATE, { datapath_id,
                      aux_id = 0
                    }).
-type ofs_state() :: #?OFS_STATE{}.

-spec init(handler_mode(), ipaddress(), datapath_id(), features(), of_version(), connection(), options()) -> {ok, ofs_state()}.
init(Mode, IpAddr, DatapathId, _Features, Version, Connection, _Opts) ->
    %% XXX store Features and opts as labels on vertex
    ok = net_observer_logic:ofsh_init(Mode, IpAddr, DatapathId, Version, Connection),
    {ok, #?OFS_STATE{datapath_id = DatapathId}}.

-spec connect(handler_mode(), ipaddress(), datapath_id(), features(), of_version(), connection(), auxid(), options()) -> {ok, ofs_state()}.
connect(Mode, IpAddr, DatapathId, _Features, Version, Connection, AuxId, _Opts) ->
    ok = net_observer_logic:ofsh_connect(Mode, IpAddr, DatapathId, Version, Connection, AuxId),
    {ok, #?OFS_STATE{datapath_id = DatapathId, aux_id = AuxId}}.

-spec disconnect(ofs_state()) -> ok.
disconnect(State) ->
    #?OFS_STATE{ datapath_id = DatapathId, aux_id = AuxId } = State,
    ok = net_observer_logic:ofsh_disconnect(AuxId, DatapathId).

-spec failover(ofs_state()) -> ok.
failover(State) ->
    % TODO: not failover not implement in ofs_handler
    ok = net_observer_logic:ofsh_failover(),
    {ok, State}.

-spec handle_error(error_reason(), ofs_state()) -> ok.
handle_error(Reason, State) ->
    % Error on the connection
    DatapathId = State#?OFS_STATE.datapath_id,
    ok = net_observer_logic:ofsh_handle_error(DatapathId, Reason).

-spec handle_message(ofp_message(), ofs_state()) -> ok.
handle_message(Msg, State) ->
    % received a message on the connection
    DatapathId = State#?OFS_STATE.datapath_id,
    ok = net_observer_logic:ofsh_handle_message(DatapathId, Msg).

-spec terminate(ofs_state()) -> ok.
terminate(State) ->
    % lost the main connection
    DatapathId = State#?OFS_STATE.datapath_id,
    ok = net_observer_logic:ofsh_terminate(DatapathId).
