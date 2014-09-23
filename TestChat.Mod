MODULE TestChat;

IMPORT KernelLog, irc := InternetRelayChat, Strings, Commands;

TYPE 
	String = irc.String;
	PChar = irc.PChar;
	PPChar= irc.PPChar;
VAR 

	cb: irc.Callbacks;

	ses: irc.Session;
	port: irc.UShort;
	server, channel, nick: ARRAY 64 OF CHAR;
	
PROCEDURE {C} EventHandle* (session: irc.Session; event,  origin: PChar; params: PPChar; count: LONGINT);
VAR res: LONGINT;
	 s: String;
BEGIN
	
	IF event # NIL THEN
		s := irc.GetStringFromAddress(event);
		KernelLog.String("event = "); KernelLog.String(s^); KernelLog.Ln; 
	END;	

	IF origin # NIL THEN
		s := irc.GetStringFromAddress(origin);
		KernelLog.String("origin = "); KernelLog.String(s^); KernelLog.Ln; 
	END;	
	
	res := irc.CmdJoin (session, channel, "");

END EventHandle;

PROCEDURE {C} EventNumericHandle* (session: irc.Session; event: irc.UInt;  origin: PChar; params: PPChar; count: LONGINT);
VAR 
	 s: String;
BEGIN
	KernelLog.String("eventN= "); KernelLog.Int(event,0); KernelLog.Ln;
	IF origin # NIL THEN
		s := irc.GetStringFromAddress(origin);
		KernelLog.String("originN = "); KernelLog.String(s^); KernelLog.Ln; 
	END;	

END EventNumericHandle;

(** *)
PROCEDURE OpenSession*(context: Commands.Context);
VAR vh, vl: irc.UInt;

BEGIN
	IF ses # NIL THEN RETURN END;
	
	port := 6667; (* port number is specified in the server string *)
	irc.GetVersion(vh, vl);
	KernelLog.String("ircclient version: "); KernelLog.Int(vh, 0); KernelLog.Char(".");  KernelLog.Int(vl, 0); KernelLog.Ln; 
	IF context.arg.GetString(server) THEN
		IF context.arg.GetString(nick) THEN
			IF context.arg.GetString(channel) THEN
				

			cb.eventConnect := EventHandle;
			cb.eventNumeric :=  EventNumericHandle;
			
			KernelLog.String("Creating session"); KernelLog.Ln; 
			ses := irc.CreateSession (ADDRESSOF(cb));
			IF ses = NIL THEN 
				KernelLog.String(" Could not create session"); KernelLog.Ln; 
				RETURN;
			END;

			
			(* If the port number is specified in the server string, use the port 0 so it gets parsed *)
			IF Strings.Pos(":", server) # -1 THEN 
				port := 0;
			END;

			KernelLog.String("server= "); KernelLog.String(server); KernelLog.Ln; 
			KernelLog.String("port= "); KernelLog.Int(port, 0); KernelLog.Ln; 			
			KernelLog.String("nick= "); KernelLog.String(nick); KernelLog.Ln; 
			KernelLog.String("channel= "); KernelLog.String(channel); KernelLog.Ln; 

		(*	KernelLog.String("Setting up session"); KernelLog.Ln; 
			irc.OptionSet(ses, {irc.OptionDebug});
		*)	
			(* Initiate the IRC server connection *)
			KernelLog.String("connecting to IRC server"); KernelLog.Ln; 
			IF irc.Connect (ses, ADDRESSOF(server), port, 0, ADDRESSOF(nick), 0, 0)  > 0 THEN
				KernelLog.String("Could not connect: "); KernelLog.String(irc.StrError (irc.Errno(ses))^);
				KernelLog.Ln; 
				RETURN;
			ELSE
				KernelLog.String("Connected.. "); KernelLog.Ln; 
			END;
			
(*			IF irc.IsConnected(ses) =1 THEN
				KernelLog.String("session CONNECTED"); KernelLog.Ln; 
			ELSE
				KernelLog.String("session IS NOT CONNECTED"); KernelLog.Ln; 
			END;
*)	
	(* and run into forever loop, generating events *)
	KernelLog.String("Running Main Event Loop"); KernelLog.Ln; 
	IF irc.Run (ses) # 0 THEN
		KernelLog.String("Could not connect or I/O error: ");
		KernelLog.String("irc.Errno(s)= "); KernelLog.Int(irc.Errno(ses), 0); KernelLog.Ln; 
		KernelLog.String(irc.StrError (irc.Errno(ses))^); KernelLog.Ln; 
		RETURN;
	END;
	
(*	KernelLog.String("Detroying session"); KernelLog.Ln; 
	irc.DestroySession(ses);
*)	
				
		ELSE
			context.error.String("usage: <server> <nick> <channel> "); context.error.Ln; context.error.Update;
		END;
	ELSE
		context.error.String("usage: <server> <nick> <channel> "); context.error.Ln; context.error.Update;
	END;
	ELSE
		context.error.String("usage: <server> <nick> <channel> "); context.error.Ln; context.error.Update;
	END;
END OpenSession;

PROCEDURE SendQuit*;
VAR res: LONGINT;
BEGIN
	IF ses = NIL THEN RETURN END;
	
	KernelLog.String("Quitting session"); KernelLog.Ln; 
	res := irc.CmdQuit(ses, "");
	IF res = 0 THEN
		KernelLog.String("Quit Send"); KernelLog.Ln; 
	ELSE
		KernelLog.String("Quit Send Error: ");
		KernelLog.String(irc.StrError (irc.Errno(ses))^); KernelLog.Ln; 

	END;
END SendQuit;

PROCEDURE SendRawQuit*;
VAR res: LONGINT;
BEGIN
	IF ses = NIL THEN RETURN END;
	
	KernelLog.String("Quitting session"); KernelLog.Ln; 
	res := irc.SendRaw1(ses, "QUIT : %s", ADDRESSOF("quit"));
	IF res = 0 THEN
		KernelLog.String("Quit SendRaw1"); KernelLog.Ln; 
	ELSE
		KernelLog.String("Quit SendRaw1 Error: ");
		KernelLog.String(irc.StrError (irc.Errno(ses))^); KernelLog.Ln; 

	END;
END SendRawQuit;

PROCEDURE SendMsg*;
VAR res: LONGINT;
BEGIN
	IF ses = NIL THEN RETURN END;
	
	KernelLog.String("Sendig message"); KernelLog.Ln; 
	res := irc.CmdMsg(ses, channel, "Hello from LinuxAos");
	IF res = 0 THEN
		KernelLog.String("CmdMsg sent"); KernelLog.Ln; 
	ELSE
		KernelLog.String("CmdMsg Error: ");
		KernelLog.String(irc.StrError (irc.Errno(ses))^); KernelLog.Ln; 
	END;
END SendMsg;

PROCEDURE SendRawMsg*;
VAR res: LONGINT;
BEGIN
	IF ses = NIL THEN RETURN END;
	
	KernelLog.String("Sending message"); KernelLog.Ln; 
	res := irc.SendRaw2(ses, "PRIVMSG %s :%s", ADDRESSOF(channel), ADDRESSOF("testing libircclient from LinuxAos,.."));
	IF res = 0 THEN
		KernelLog.String("Quit SendRaw1"); KernelLog.Ln; 
	ELSE
		KernelLog.String("Quit SendRaw1 Error: ");
		KernelLog.String(irc.StrError (irc.Errno(ses))^); KernelLog.Ln; 

	END;
END SendRawMsg;

PROCEDURE CloseSession*;
BEGIN
	KernelLog.String("Destroying, Closing session"); KernelLog.Ln;
	IF ses # NIL THEN
		irc.DestroySession(ses);
		ses := NIL;
	END;	
END CloseSession;

BEGIN
	
END TestChat.


	TestChat.OpenSession irc.freenode.net  linuxaos  #spasim ~

			TestChat.SendMsg ~ TestChat.SendRawMsg ~ 

			TestChat.SendQuit ~   TestChat.SendRawQuit ~ 

	TestChat.CloseSession ~ 

SystemTools.Free  TestChat ~

SystemTools.FreeDownTo InternetRelayChat ~ 


