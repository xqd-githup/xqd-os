
void start_kernel()
{
	long vga = 0xffffffff800b8000;
	for( int i = 0 ; i < 10 ; i ++)
		*(char*)(vga +80*6+ i*2 ) = 'X';

	while( 1 ) ;
}