# Based on grammar generated by [abnfgen][1] at Mon Mar 24 05:50:55 2014
# Sources:
#       core
#       ../../packet-abnf_grammar.txt
#
# [1]: http://www.2p.cz/en/abnf_gen/
%%{
    # write your name
    machine packet_grammar;

    alphtype unsigned char;

    # generated rules, define required actions
    ALPHA = 0x41..0x5a | 0x61..0x7a;
    BIT = "0" | "1";
    CHAR = 0x01..0x7f;
    CR = "\r";
    LF = "\n";
    CRLF = CR LF;
    CTL = 0x00..0x1f | 0x7f;
    DIGIT = 0x30..0x39;
    DQUOTE = "\"";
    HEXDIG = DIGIT | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
    HTAB = "\t";
    SP = " ";
    WSP = SP | HTAB;
    LWSP = ( WSP | ( CRLF WSP ) )*;
    OCTET = 0x00..0xff;
    VCHAR = 0x21..0x7e;

    startflag = "|"{3};
    iuid = OCTET{2};
    length = OCTET{2};
    payload = OCTET*;
    crc = OCTET{2};

    ACK = 'a';
    NACK = 'n';
    DATA = 'd';
    STREAM = 's';

    # The `process_payload` state machine parses incoming bytes into the packet
    # buffer until the expected number of bytes has been read.
    process_payload := (
        payload >payload_start $payload_byte_received
    );

    # The `Hub` rule defines the states of the packet parser.
    Hub = (
        start: (
            (startflag @startflag_received)
            (iuid >id_start $id_octet_received)
            (ACK >type_received @ack_received -> final |
             NACK >type_received -> ProcessingNack |
             STREAM >type_received -> ProcessingData |
             DATA >type_received -> ProcessingData)
        ),

        ProcessingNack: (
            length @length_received @nack_received -> final
        ),

        ProcessingData: (
            (length >length_start $length_byte_received @length_received @{ fcall process_payload; } %payload_end)
            (crc >crc_start $crc_byte_received @crc_received) -> final
        )
    ); # $!error;
    #) ${ std::cout << "[byte_received] " << std::hex << static_cast<int>(*p) << std::dec << std::endl; } $!error;
    main := Hub* ;
}%%
