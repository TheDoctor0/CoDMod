
#if defined _sockets2_included
	#endinput
#endif
#define _sockets2_included

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib sockets2
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib sockets2
 #endif
#else
 #pragma library socket2
#endif

#define SOCKET_TCP 1
#define SOCKET_UDP 2

native socket_open(const _hostname[], _port, _protocol = SOCKET_TCP, &_error);
native socket_listen(const _hostname[], _port, _protocol = SOCKET_TCP, &_error);
native socket_close(_socket);
native socket_accept(_socket,&_error);
native socket_recv(_socket, _data[], _length);
native socket_send(_socket, const _data[], _length);
native socket_send2(_socket, const _data[], _length);
native socket_change(_socket);
native bool:socket_is_writable(_socket);
native socket_dataavailable(_socket);
native socket_getpeeraddr(_socket,_dest[],_max,&_port,&_error);
