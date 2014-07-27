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

CONST
	LibName = 'libircclient.so';
	
	(* Error codes *)
	ErrOk = 0;
	ErrInval = 1;
	ErrResolv = 2;
	ErrSocket = 3;
	ErrConnect = 4;
	ErrClosed = 5;
	ErrNomem = 6;
	ErrAccept = 7;
	(* 8 is missing *)
	ErrNoDccSend = 9;
	ErrRead = 10;
	ErrWrite = 11;
	ErrState = 12;
	ErrTimeout = 13;
	ErrOpenFile = 14;
	ErrTerminated = 15;
	ErrNoipv6 = 16;
	ErrSslNotSupported = 17;
	ErrSslInitFailed = 18;
	ErrConnectSslFailed = 19;
	ErrSslCertVerifyFailed = 20;
	ErrMax = 21;
	
	(* Options *)
	OptionDebug = 2;
	OptionStripNicks = 4;
	OptionSslNoVerify = 8;
	
	(* RFC codes *)
	RfcRplWelcome = 001;
	RfcRplYourHost = 002;
	RfcRplCreated = 003;
	RfcRplMyInfo = 004;
	RfcRplBounce = 005;
	RfcRplUserHost = 302;
	RfcRplIsOn = 303;
	RfcRplAway = 301;
	RfcRplUnAayY = 305;
	RfcRplNowAway = 306;
	RfcRplWhoisUser = 311;
	RfcRplWhoisServer = 312;
	RfcRplWhoisOperator = 313;
	RfcRplWhoisIdle = 317;
	RfcRplEndOfWhois = 318;
	RfcRplWhoisChannels = 319;
	RfcRplWhowasUser = 314;
	RfcRplEndofWhowas = 369;
	RfcRplList = 322;
	RfcRplListEnd = 323;
	RfcRplUniqOpis = 325;
	RfcRplChannelModeIs = 324;
	RfcRplNoTopic = 331;
	RfcRplTopic = 332;
	RfcRplInviting = 341;
	RfcRplSummoning = 342;
	RfcRplInviteList = 346;
	RfcRplEndOfInviteList = 347;
	RfcRplExceptList = 348;
	RfcRplEndOfExceptList = 349;
	RfcRplVersion = 351;
	RfcRplWhoReply = 352;
	RfcRplEndOfWho = 315;
	RfcRplNamReply = 353;
	RfcRplEndOfNames = 366;
	RfcRplLinks = 364;
	RfcRplEndOfLinks = 365;
	RfcRplBanList = 367;
	RfcRplEndOfBanList = 368;
	RfcRplInfo = 371;
	RfcRplEndOfInfo = 374;
	RfcRplMotdStart = 375;
	RfcRplMotd = 372;
	RfcRplEndOfMotd = 376;
	RfcRplYoureOper = 381;
	RfcRplRehashing = 382;
	RfcRplYoureService = 383;
	RfcRplTime = 391;
	RfcRplUsersStart = 392;
	RfcRplUsers = 393;
	RfcRplEndOfUsers = 394;
	RfcRplNoUsers = 395;
	RfcRplTraceLink = 200;
	RfcRplTraceConnecting = 201;
	RfcRplTraceHandShake = 202;
	RfcRplTraceUnknown = 203;
	RfcRplTraceOperator = 204;
	RfcRplTraceUser = 205;
	RfcRplTraceServer = 206;
	RfcRplTraceService = 207;
	RfcRplTraceNewtype = 208;
	RfcRplTraceClass = 209;
	RfcRplTraceLog = 261;
	RfcRplTraceEnd = 262;
	RfcRplStatsLinkInfo = 211;
	RfcRplStatsCommands = 212;
	RfcRplEndOfStats = 219;
	RfcRplSstatUptime = 242;
	RfcRplStatsOLine = 243;
	RfcRplUmodeIs = 221;
	RfcRplServList = 234;
	RfcRplServListEnd = 235;
	RfcRplLUserClient = 251;
	RfcRplLUserOp = 252;
	RfcRplLUserUnknown = 253;
	RfcRplLUserChannels = 254;
	RfcRplLUserMe = 255;
	RfcRplAdminME = 256;
	RfcRplAdminLoc1 = 257;
	RfcRplAdminLoc2 = 258;
	RfcRplAdminEmail = 259;
	RfcRplTryAgain = 263;
	RfcErrNoSuchNIck = 401;
	RfcErrNoSuchServer = 402;
	RfcErrNoSuchChannel = 403;
	RfcErrCannotSendToChan = 404;
	RfcErrTooManyChannels = 405;
	RfcErrWasNoSuchNick = 406;
	RfcErrTooManyTargets = 407;
	RfcErrNoSuchService = 408;
	RfcErrNoOrigin = 409;
	RfcErrNoRecipient = 411;
	RfcErrNoTextToSend = 412;
	RfcErrNoTopLevel = 413;
	RfcErrWildTopLevel = 414;
	RfcErrBadMask = 415;
	RfcErrUnknownCommand = 421;
	RfcErrNoMotd = 422;
	RfcErrNoAdminInfo = 423;
	RfcErrFileError = 424;
	RfcErrNoNickNameGiven = 431;
	RfcErrErroneusNickname = 432;
	RfcErrNicknameInUse = 433;
	RfcErrNickCollision = 436;
	RfcErrUnavailResource = 437;
	RfcErrUserNotInChannel = 441;
	RfcErrNotOnChannel = 442;
	RfcErrUserOnChannel = 443;
	RfcErrNoLogin = 444;
	RfcErrSummonDisabled = 445;
	RfcErrUsersDisabled = 446;
	RfcErrNotRegistered = 451;
	RfcErrNeedMoreParams = 461;
	RfcErrAlreadyRegistered = 462;
	RfcErrNoPermForHost = 463;
	RfcErrPasswdMismatch = 464;
	RfcErrYoureBannedCreep = 465;
	RfcErrYouWillBeBanned = 466;
	RfcErrKeyset = 467;
	RfcErrChannelIsFull = 471;
	RfcErrUnknownMode = 472;
	RfcErrInviteOnlyChan = 473;
	RfcErrBannedFromChan = 474;
	RfcErrBadChannelKey = 475;
	RfcErrBadChanMask = 476;
	RfcErrNoChanModes = 477;
	RfcErrBanListFull = 478;
	RfcErrNoPrivileges = 481;
	RfcErrChanoPrivsNeeded = 482;
	RfcErrCantKillServer = 483;
	RfcErrRestricted = 484;
	RfcErrUniqopPrivsNeeded = 485;
	RfcErrNoOperHost = 491;
	RfcErrUmodeUnknownFlag = 501;
	RfcErrUsersDontMatch = 502;

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
