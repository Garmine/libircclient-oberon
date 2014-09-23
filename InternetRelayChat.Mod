MODULE InternetRelayChat;

IMPORT Unix, Modules, SYSTEM, Strings;

TYPE
	String* = Strings.String;
	
	(* Structs/similars *)
	Session* = ADDRESS;
	DccSession* = ADDRESS;
	(*Callbacks* = ADDRESS;*)
	FdSet* = ADDRESS;
	Dcc* = UNSIGNED32;
	(* DccCallback* = ADDRESS; *)
	
	(* C types *)
	PChar* = ADDRESS; 	
	PPChar* = ADDRESS;
	
	UShort* = UNSIGNED16;
	UInt* = UNSIGNED32;
	Size* = SIZE;

TYPE
	DccCallbackProc* = PROCEDURE {C} (session: Session; id: Dcc; status: LONGINT; ctx: ADDRESS; data: ADDRESS; length: LONGINT);

CONST
(* libirc_options.h, bits *)
	OptionDebug* = 1; (* enables additional debug output  *)
	OptionStripNicks* = 2; (* allows to strip origins automatically *)
	OptionSSLnoVerify* = 3; (* Disables the certificate verification for SSL connections *)
	
TYPE 
	(* libirc_events.h*)
	EventCallbackProc* = PROCEDURE {C} (session: Session; event, origin: PChar; params: PPChar; count: LONGINT);
	EventCodeCallbackProc* = PROCEDURE {C} (session: Session; event: UInt; origin: PChar;  params: PPChar; count: LONGINT);
	EventDccChatProc* = PROCEDURE {C} (session: Session; nick,  addr: PChar; dccid: Dcc);
	EventDccSendProc* =  PROCEDURE {C} (session: Session; nick,  addr, filename: PChar; size: LONGINT; dccid: Dcc);

TYPE 
	Callbacks* =  RECORD
		eventConnect*: EventCallbackProc;
		eventNick*: EventCallbackProc;
		eventQuit* : EventCallbackProc;
		eventJoin* : EventCallbackProc;
		eventPart* : EventCallbackProc;
		eventMode* : EventCallbackProc;
		eventUmode*: EventCallbackProc;
		eventTopic* : EventCallbackProc;
		eventKick* : EventCallbackProc;
		eventChannel* : EventCallbackProc;
		eventPrivMsg* : EventCallbackProc;
		eventNotice* : EventCallbackProc;
		eventChannelNotice* : EventCallbackProc;
		eventInvite* : EventCallbackProc;
		eventCtcpReq* : EventCallbackProc;
		eventCtcpRep* : EventCallbackProc;
		eventCtcpAction* : EventCallbackProc;
		eventUnknown* : EventCallbackProc;
		eventNumeric* : EventCodeCallbackProc;
		eventDccChatReq* : EventDccChatProc;
		eventDccSendReq* : EventDccSendProc;
	END;
	
 (* ========================= *)
 
VAR
	Lib: ADDRESS;

	(* --- Functions --- *)

	(* Session/connection/similar *)
	CreateSession-: PROCEDURE{C}(callbacks: ADDRESS): Session;
	DestroySession-: PROCEDURE{C}(session: Session);
	Connect-: PROCEDURE{C}(session: Session;  server: PChar; port: UShort;
									password, nick, username, realname: PChar): LONGINT;
	Connect6-: PROCEDURE{C}(session: Session; server: PChar; port: UShort;
									password, nick, username, realname: PChar): LONGINT;
	Disconnect-: PROCEDURE{C}(session: Session);
	IsConnected-: PROCEDURE{C}(session: Session): LONGINT;
	Run-: PROCEDURE{C}(session: Session): LONGINT;
	AddSelectDescriptors-: PROCEDURE{C}(session: Session; inSet: FdSet; 
													outSet: FdSet; VAR maxfd: LONGINT): LONGINT;
	ProcessSelectDescriptors-: PROCEDURE{C}(session: Session; inSet: FdSet; 
													outSet: FdSet): LONGINT;
	
	(* SendRaw-: PROCEDURE{C}(session: Session; format: PChar; ...): LONGINT; *)
	
	(* SendRaw definition up to 4 variables*)
	SendRaw-: PROCEDURE{C}(session: Session; CONST format: ARRAY OF CHAR): LONGINT;
	SendRaw1-: PROCEDURE{C}(session: Session; CONST format: ARRAY OF CHAR; var1: ADDRESS): LONGINT;
	SendRaw2-: PROCEDURE{C}(session: Session; CONST format: ARRAY OF CHAR; var1, var2: ADDRESS): LONGINT;
	SendRaw3-: PROCEDURE{C}(session: Session; CONST format: ARRAY OF CHAR; var1, var2, var3: ADDRESS): LONGINT;
	SendRaw4-: PROCEDURE{C}(session: Session; CONST format: ARRAY OF CHAR; var1, var2, var3, var4: ADDRESS): LONGINT;


	(* IRC commands *)
	CmdQuit-: PROCEDURE{C}(session: Session; CONST reason: ARRAY OF CHAR): LONGINT;
	CmdJoin-: PROCEDURE{C}(session: Session; CONST channel, key: ARRAY OF CHAR): LONGINT;
	CmdPart-: PROCEDURE{C}(session: Session; CONST channel: ARRAY OF CHAR): LONGINT;
	CmdInvite-: PROCEDURE{C}(session: Session; CONST nick, channel: ARRAY OF CHAR): LONGINT;
	CmdNames-: PROCEDURE{C}(session: Session; CONST channel: ARRAY OF CHAR): LONGINT;
	CmdList-: PROCEDURE{C}(session: Session; CONST channel: ARRAY OF CHAR): LONGINT;
	CmdTopic-: PROCEDURE{C}(session: Session; CONST channel, topic: ARRAY OF CHAR): LONGINT;
	CmdChannelMode-: PROCEDURE{C}(session: Session; CONST channel, mode: ARRAY OF CHAR): LONGINT;
	CmdUserMode-: PROCEDURE{C}(session: Session; CONST mode: ARRAY OF CHAR): LONGINT;
	CmdNick-: PROCEDURE{C}(session: Session; CONST newnick: ARRAY OF CHAR): LONGINT;
	CmdWhois-: PROCEDURE{C}(session: Session; CONST nick: ARRAY OF CHAR): LONGINT;
	CmdMsg-: PROCEDURE{C}(session: Session; CONST nch, text: ARRAY OF CHAR): LONGINT;
	CmdMe-: PROCEDURE{C}(session: Session; CONST nch, text: ARRAY OF CHAR): LONGINT;
	CmdNotice-: PROCEDURE{C}(session: Session; CONST nch,  text: ARRAY OF CHAR): LONGINT;
	CmdKick-: PROCEDURE{C}(session: Session; CONST nick, channel, reason: ARRAY OF CHAR): LONGINT;
	CmdCtcpRequest-: PROCEDURE{C}(session: Session; CONST nick, request: ARRAY OF CHAR): LONGINT;
	CmdCtcpReply-: PROCEDURE{C}(session: Session; CONST nick, reply: ARRAY OF CHAR): LONGINT;
	
	(* Helpers *)
	TargetGetNick-: PROCEDURE{C}(CONST target: ARRAY OF CHAR; nick: PChar; size: Size);
	TargetGetHost-: PROCEDURE{C}(CONST target: ARRAY OF CHAR; nick: PChar; size: Size);
	
	(* DCC *)
	DccChat-: PROCEDURE{C}(session: Session; ctx: ADDRESS; CONST nick: ARRAY OF CHAR; 
							callback: DccCallbackProc; dccid: Dcc): LONGINT;
	DccMsg-: PROCEDURE{C}(session: Session; dccid: Dcc; CONST text: ARRAY OF CHAR): LONGINT;
	DccAccept-: PROCEDURE{C}(session: Session; dccid: Dcc; ctx: ADDRESS; callback: DccCallbackProc): LONGINT;
	DccDecline-: PROCEDURE{C}(session: Session; dccid: Dcc): LONGINT;
	DccSendFile-: PROCEDURE{C}(session: Session; ctx: ADDRESS; CONST nick: ARRAY OF CHAR; 
								CONST filename: ARRAY OF CHAR; callback: DccCallbackProc; dccid: Dcc): LONGINT;
	DccDestroy-: PROCEDURE{C}(session: Session; dccid: Dcc): LONGINT;
	
	(* User defined context - ctx *)
	SetCtx-: PROCEDURE{C}(session: Session; ctx: ADDRESS);
	GetCtx-: PROCEDURE{C}(session: Session): ADDRESS;
	
	(* Errors *)
	Errno-: PROCEDURE{C}(session: Session): LONGINT;
	strError: PROCEDURE{C}(ircerrno: LONGINT): ADDRESS;
	
	(* Options *)
	OptionSet-: PROCEDURE{C}(session: Session; option: SET);
	OptionReset-: PROCEDURE{C}(session: Session; option: SET);

	(* mIRC color magic *)
	ColorStripFromMirc-: PROCEDURE{C}(message: PChar): PChar;
	ColorConvertFromMirc-: PROCEDURE{C}(message: PChar): PChar;
	ColorConvertToMirc-: PROCEDURE{C}(message: PChar): PChar;
	
	(* ETC *)
	GetVersion-: PROCEDURE{C}(VAR high, low: UInt);
	SetCtcpVersion-: PROCEDURE{C}(session: Session; version: PChar);

CONST
	LibName = 'libircclient.so';

PROCEDURE Link;
BEGIN
	Unix.Dlsym(Lib, "irc_create_session", ADDRESSOF(CreateSession));
	Unix.Dlsym(Lib, "irc_destroy_session", ADDRESSOF(DestroySession));
	Unix.Dlsym(Lib, "irc_connect", ADDRESSOF(Connect));
	Unix.Dlsym(Lib, "irc_connect6", ADDRESSOF(Connect6));
	Unix.Dlsym(Lib, "irc_disconnect", ADDRESSOF(Disconnect));
	Unix.Dlsym(Lib, "irc_is_connected", ADDRESSOF(IsConnected));
	Unix.Dlsym(Lib, "irc_run", ADDRESSOF(Run));
	Unix.Dlsym(Lib, "irc_add_select_descriptors", ADDRESSOF(AddSelectDescriptors));
	Unix.Dlsym(Lib, "irc_process_select_descriptors", ADDRESSOF(ProcessSelectDescriptors));

	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw));
	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw1));
	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw2));
	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw3));
	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw4));
	
	Unix.Dlsym(Lib, "irc_cmd_quit", ADDRESSOF(CmdQuit));
	Unix.Dlsym(Lib, "irc_cmd_join", ADDRESSOF(CmdJoin));
	Unix.Dlsym(Lib, "irc_cmd_part", ADDRESSOF(CmdPart));
	Unix.Dlsym(Lib, "irc_cmd_invite", ADDRESSOF(CmdInvite));
	Unix.Dlsym(Lib, "irc_cmd_names", ADDRESSOF(CmdNames));
	Unix.Dlsym(Lib, "irc_cmd_list", ADDRESSOF(CmdList));
	Unix.Dlsym(Lib, "irc_cmd_topic", ADDRESSOF(CmdTopic));
	Unix.Dlsym(Lib, "irc_cmd_channel_mode", ADDRESSOF(CmdChannelMode));
	Unix.Dlsym(Lib, "irc_cmd_user_mode", ADDRESSOF(CmdUserMode));
	Unix.Dlsym(Lib, "irc_cmd_nick", ADDRESSOF(CmdNick));
	Unix.Dlsym(Lib, "irc_cmd_whois", ADDRESSOF(CmdWhois));
	Unix.Dlsym(Lib, "irc_cmd_msg", ADDRESSOF(CmdMsg));
	Unix.Dlsym(Lib, "irc_cmd_me", ADDRESSOF(CmdMe));
	Unix.Dlsym(Lib, "irc_cmd_notice", ADDRESSOF(CmdNotice));
	Unix.Dlsym(Lib, "irc_cmd_kick", ADDRESSOF(CmdKick));
	Unix.Dlsym(Lib, "irc_cmd_ctcp_request", ADDRESSOF(CmdCtcpRequest));
	Unix.Dlsym(Lib, "irc_cmd_ctcp_reply", ADDRESSOF(CmdCtcpReply));
	Unix.Dlsym(Lib, "irc_target_get_nick", ADDRESSOF(TargetGetNick));
	Unix.Dlsym(Lib, "irc_target_get_host", ADDRESSOF(TargetGetHost));
	Unix.Dlsym(Lib, "irc_dcc_chat", ADDRESSOF(DccChat));
	Unix.Dlsym(Lib, "irc_dcc_msg", ADDRESSOF(DccMsg));
	Unix.Dlsym(Lib, "irc_dcc_accept", ADDRESSOF(DccAccept));
	Unix.Dlsym(Lib, "irc_dcc_decline", ADDRESSOF(DccDecline));
	Unix.Dlsym(Lib, "irc_dcc_sendfile", ADDRESSOF(DccSendFile));
	Unix.Dlsym(Lib, "irc_dcc_destroy", ADDRESSOF(DccDestroy));
	Unix.Dlsym(Lib, "irc_set_ctx", ADDRESSOF(SetCtx));
	Unix.Dlsym(Lib, "irc_get_ctx", ADDRESSOF(GetCtx));
	Unix.Dlsym(Lib, "irc_errno", ADDRESSOF(Errno));
	Unix.Dlsym(Lib, "irc_strerror", ADDRESSOF(strError));
	Unix.Dlsym(Lib, "irc_option_set", ADDRESSOF(OptionSet));
	Unix.Dlsym(Lib, "irc_option_reset", ADDRESSOF(OptionReset));
	Unix.Dlsym(Lib, "irc_color_strip_from_mirc", ADDRESSOF(ColorStripFromMirc));
	Unix.Dlsym(Lib, "irc_color_convert_from_mirc", ADDRESSOF(ColorConvertFromMirc));
	Unix.Dlsym(Lib, "irc_color_convert_to_mirc", ADDRESSOF(ColorConvertToMirc));
	Unix.Dlsym(Lib, "irc_get_version", ADDRESSOF(GetVersion));
(*	Unix.Dlsym(Lib, "irc_set_ctcp_version", ADDRESSOF(SetCtcpVersion)); *)
END Link;

(* helper procedure *)
PROCEDURE GetStringFromAddress*(adr: ADDRESS): String;
VAR
	adr1: ADDRESS;
	name: String;
	i, cnt: LONGINT;
	ch: CHAR;
BEGIN
	cnt := 0;
	adr1 := adr;
	(* count # of characters *)
	SYSTEM.GET(adr1, ch); 
	WHILE ch # 0X DO
		INC(cnt); INC(adr1);
		SYSTEM.GET(adr1, ch);
	END;
	IF cnt > 0 THEN
		(* copy characters to name *)
		adr1 := adr;
		NEW(name, cnt);
		FOR i :=0 TO cnt-1 DO
			SYSTEM.GET(adr1, ch); name[i] := ch; INC(adr1);
		END;
	END;
	RETURN name;		
END GetStringFromAddress;

(* wrapper proc for strError *)
PROCEDURE StrError*(err: LONGINT): String;
VAR adr: ADDRESS;
	s: String;
BEGIN
	adr := strError(err);
	s := GetStringFromAddress(adr);
	RETURN s;
END StrError;

PROCEDURE Init;
BEGIN
	Lib := Unix.Dlopen(LibName, 2);
	ASSERT(Lib # 0, 333);
END Init;

PROCEDURE OnClose;
BEGIN
	IF Lib # 0 THEN
		Unix.Dlclose(Lib);
	END;
END OnClose;

BEGIN
	Init();
	Link();
	Modules.InstallTermHandler(OnClose);
END InternetRelayChat.
