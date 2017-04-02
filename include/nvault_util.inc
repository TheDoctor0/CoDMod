
/*	
	nVault Utility
	     v0.1
	   by bugsy
*/

#if defined _nvault_util_included
	#endinput
#endif
#define _nvault_util_included

#if !defined _nvault_included
	#include <nvault>
#endif

#if !defined _amxmisc_included
	#include <amxmisc>
#endif

#define MAX_KEY_LEN	255
#define MAX_VAL_LEN	512
#define BUFFER_SIZE	128

#define OFFSET_ENTRYCOUNT	6
#define OFFSET_DATASTART	10

#define MinSize(%1,%2)	(%1<%2?%1:%2)

stock nvault_util_open( const szVault[] )
{
	new szFile[ 64 ];
	
	formatex( szFile[ get_datadir( szFile , charsmax( szFile ) ) ] , charsmax( szFile ) , "/vault/%s.vault" , szVault );
	
	return fopen( szFile , "rb" );
}

stock nvault_util_close( iVaultHandle )
{
	fclose( iVaultHandle );
}

stock nvault_util_count( iVaultHandle )
{
	new DataBuffer[ 1 ];

	fseek( iVaultHandle , OFFSET_ENTRYCOUNT , SEEK_SET );
	fread_raw( iVaultHandle , DataBuffer , 1 , BLOCK_INT );
	
	return DataBuffer[ 0 ];
}

stock nvault_util_read( iVaultHandle , iOffset , szKey[] , iKeySize , szVal[] , iValSize , &iTimeStamp )
{
	static iKeyLen , iValLen , DataBuffer[ BUFFER_SIZE ];
	
	fseek( iVaultHandle , iOffset ? iOffset : OFFSET_DATASTART , SEEK_SET );
	
	fread_raw( iVaultHandle , DataBuffer , 1 , BLOCK_INT );
	iTimeStamp = DataBuffer[ 0 ];
	
	fread_raw( iVaultHandle , DataBuffer , 1 , BLOCK_BYTE );
	iKeyLen = DataBuffer[ 0 ] & 0xFF;
	
	fread_raw( iVaultHandle , DataBuffer , 1 , BLOCK_SHORT );
	iValLen = DataBuffer[ 0 ] & 0xFFFF;
	
	fread_raw( iVaultHandle , DataBuffer , iKeyLen , BLOCK_CHAR );
	ReadString( szKey , MinSize( iKeySize , iKeyLen ) , DataBuffer , sizeof( DataBuffer ) );
	
	fread_raw( iVaultHandle , DataBuffer , iValLen , BLOCK_CHAR );
	ReadString( szVal , MinSize( iValSize , iValLen ) , DataBuffer , sizeof( DataBuffer ) );
	
	return ftell( iVaultHandle );
}

stock nvault_util_readall( iVaultHandle , const szForwardFunc[] , Data[] = {0} , iSize=0 )
{
	new iFwdHandle = CreateMultiForward( szForwardFunc , ET_IGNORE , FP_CELL , FP_CELL , FP_STRING , FP_STRING , FP_CELL , FP_STRING , FP_CELL );
	
	if ( iFwdHandle <= 0 )
		set_fail_state( "nvault_util_readall() failed to create forward" );
		
	new iRet , iPos , iNumEntries = nvault_util_count( iVaultHandle );
	new szKey[ MAX_KEY_LEN ] , szValue[ MAX_VAL_LEN ] , iTimeStamp;

	for ( new iCurrent = 1 ; iCurrent <= iNumEntries ; iCurrent++ )
	{
		iPos = nvault_util_read( iVaultHandle , iPos , szKey , charsmax( szKey ) , szValue , charsmax( szValue ) , iTimeStamp );
		
		ExecuteForward( iFwdHandle , iRet , iCurrent , iNumEntries , szKey , szValue , iTimeStamp , Data , iSize );
	}
	
	return iRet;
}

stock nvault_util_pos( iVaultHandle )
{
	return ftell( iVaultHandle );
}

stock ReadString( szDestString[] , iMaxLen , const SourceData[] , iSourceSize )
{
	/*    Memory layout
	szDest[ 0 ] = Source{ 3 }
	szDest[ 1 ] = Source{ 2 }
	szDest[ 2 ] = Source{ 1 }
	szDest[ 3 ] = Source{ 0 }
	szDest[ 4 ] = Source{ 7 }
	szDest[ 5 ] = Source{ 6 }
	szDest[ 6 ] = Source{ 5 }
	szDest[ 7 ] = Source{ 4 }
	szDest[ 8 ] = Source{ 11 }
	*/
	   
	new iDestPos = -1;
	new iBytePos = 4;
	new iOffset = 1;
	new iSourceMax = ( iSourceSize * 4 );
	
	while ( ( ++iDestPos < iMaxLen ) && ( iBytePos < iSourceMax ) )
	{
		szDestString[ iDestPos ] = SourceData{ iBytePos - iOffset++ };

		if ( iDestPos && ( ( iDestPos % 4 ) == 3 ) )
		{
			iBytePos += 4;
			iOffset = 1;
		}
	}
	
	szDestString[ iDestPos ] = EOS;
}
