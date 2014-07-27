MODULE InternetRelayChat;

IMPORT Unix, Modules, Trace;

TYPE
	(* Structs/similars *)
	Session* = ADDRESS;
	DccSession* = ADDRESS;
	Callbacks* = ADDRESS;
	FdSet* = ADDRESS;
	Dcc* = UNSIGNED32;
	DccCallback* = ADDRESS;
	
	(* C types *)
	PChar = ADDRESS;
	PInt = ADDRESS;
	PUint = ADDRESS; 
	UShort = UNSIGNED16;
	UInt = UNSIGNED32;
	Size = SIZE;

VAR
	Lib: ADDRESS;

	(* --- Functions --- *)

	(* Session/connection/similar *)
	CreateSession-: PROCEDURE{C}(callbacks: Callbacks): Session;
	DestroySession-: PROCEDURE{C}(session: Session);
	Connect-: PROCEDURE{C}(session: Session; server: PChar; port: UShort;
									password: PChar; nick: PChar; 
									username: PChar; realname: PChar): INTEGER;
	Connect6-: PROCEDURE{C}(session: Session; server: PChar; port: UShort;
									password: PChar; nick: PChar;
									username: PChar; realname: PChar): INTEGER;
	Disconnect-: PROCEDURE{C}(session: Session);
	IsConnected-: PROCEDURE{C}(session: Session): INTEGER;
	Run-: PROCEDURE{C}(session: Session): INTEGER;
	AddSelectDescriptors-: PROCEDURE{C}(session: Session; inSet: FdSet; 
													outSet: FdSet; maxfd: PInt): INTEGER;
	ProcessSelectDescriptors-: PROCEDURE{C}(session: Session; inSet: FdSet; 
													outSet: FdSet): INTEGER;
	
(*	SendRaw-: PROCEDURE{C}(session: Session; format: PChar, ...): INTEGER; ? *)
	
	(* IRC commands *)
	CmdQuit-: PROCEDURE{C}(session: Session; reason: PChar): INTEGER;
	CmdJoin-: PROCEDURE{C}(session: Session; channel: PChar; key: PChar): INTEGER;
	CmdPart-: PROCEDURE{C}(session: Session; channel: PChar): INTEGER;
	CmdInvite-: PROCEDURE{C}(session: Session; nick: PChar; channel: PChar): INTEGER;
	CmdNames-: PROCEDURE{C}(session: Session; channel: PChar): INTEGER;
	CmdList-: PROCEDURE{C}(session: Session; channel: PChar): INTEGER;
	CmdTopic-: PROCEDURE{C}(session: Session; channel: PChar; topic: PChar): INTEGER;
	CmdChannelMode-: PROCEDURE{C}(session: Session; channel: PChar; mode: PChar): INTEGER;
	CmdUserMode-: PROCEDURE{C}(session: Session; mode: PChar): INTEGER;
	CmdNick-: PROCEDURE{C}(session: Session; newnick: PChar): INTEGER;
	CmdWhois-: PROCEDURE{C}(session: Session; nick: PChar): INTEGER;
	CmdMsg-: PROCEDURE{C}(session: Session; nch: PChar; text: PChar): INTEGER;
	CmdMe-: PROCEDURE{C}(session: Session; nch: PChar; text: PChar): INTEGER;
	CmdNotice-: PROCEDURE{C}(session: Session; nch: PChar; text: PChar): INTEGER;
	CmdKick-: PROCEDURE{C}(session: Session; nick: PChar; channel: PChar; reason: PChar): INTEGER;
	CmdCtcpRequest-: PROCEDURE{C}(session: Session; nick: PChar; request: PChar): INTEGER;
	CmdCtcpReply-: PROCEDURE{C}(session: Session; nick: PChar; reply: PChar): INTEGER;
	
	(* Helpers *)
	TargetGetNick-: PROCEDURE{C}(target: PChar; nick: PChar; size: Size);
	TargetGetHost-: PROCEDURE{C}(target: PChar; nick: PChar; size: Size);
	
	(* DCC *)
	DccChat-: PROCEDURE{C}(session: Session; ctx: ADDRESS; nick: PChar; 
							callback: DccCallback; dccid: Dcc): INTEGER;
	DccMsg-: PROCEDURE{C}(session: Session; dccid: Dcc; text: PChar): INTEGER;
	DccAccept-: PROCEDURE{C}(session: Session; dccid: Dcc; ctx: ADDRESS; callback: DccCallback): INTEGER;
	DccDecline-: PROCEDURE{C}(session: Session; dccid: Dcc): INTEGER;
	DccSendFile-: PROCEDURE{C}(session: Session; ctx: ADDRESS; nick: PChar; 
								filename: PChar; callback: DccCallback; dccid: Dcc): INTEGER;
	DccDestroy-: PROCEDURE{C}(session: Session; dccid: Dcc): INTEGER;
	
	(* User defined context - ctx *)
	SetCtx-: PROCEDURE{C}(session: Session; ctx: ADDRESS);
	GetCtx-: PROCEDURE{C}(session: Session): ADDRESS;
	
	(* Errors *)
	Errno-: PROCEDURE{C}(session: Session): INTEGER;
	StrError-: PROCEDURE{C}(ircerrno: INTEGER): PChar;
	
	(* Options *)
	OptionSet-: PROCEDURE{C}(session: Session; option: UInt);
	OptionReset-: PROCEDURE{C}(session: Session; option: UInt);

	(* mIRC color magic *)
	ColorStripFromMirc-: PROCEDURE{C}(message: PChar): PChar;
	ColorConvertFromMirc-: PROCEDURE{C}(message: PChar): PChar;
	ColorConvertToMirc-: PROCEDURE{C}(message: PChar): PChar;
	
	(* ETC *)
	GetVersion-: PROCEDURE{C}(high: PUint; low: PUint);
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
(*	Unix.Dlsym(Lib, "irc_send_raw", ADDRESSOF(SendRaw)); *)
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
	Unix.Dlsym(Lib, "irc_strerror", ADDRESSOF(StrError));
	Unix.Dlsym(Lib, "irc_option_set", ADDRESSOF(OptionSet));
	Unix.Dlsym(Lib, "irc_option_reset", ADDRESSOF(OptionReset));
	Unix.Dlsym(Lib, "irc_color_strip_from_mirc", ADDRESSOF(ColorStripFromMirc));
	Unix.Dlsym(Lib, "irc_color_convert_from_mirc", ADDRESSOF(ColorConvertFromMirc));
	Unix.Dlsym(Lib, "irc_color_convert_to_mirc", ADDRESSOF(ColorConvertToMirc));
	Unix.Dlsym(Lib, "irc_get_version", ADDRESSOF(GetVersion));
(*	Unix.Dlsym(Lib, "irc_set_ctcp_version", ADDRESSOF(SetCtcpVersion)); *)
END Link;

PROCEDURE Init;
BEGIN
	Lib := Unix.Dlopen(LibName, 2);
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