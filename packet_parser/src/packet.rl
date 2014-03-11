# Generated by abnfgen at Thu Nov  7 09:13:53 2013
# Sources:
#     core
#     packet-abnf_grammar.txt
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
    startflag = "~~s~~";
    command_with_type_msb = 0x00..0xff;
    payloadlength = (0x00..0x7f @payloadlength_single) |
                    (0x80..0xff @payloadlength_msb
                     OCTET @payloadlength_lsb);
    payload = OCTET*;
    crc = OCTET{2};
    endflag = "!";

    header = (command_with_type_msb @command_received)
             (payloadlength >payloadlength_start);

    process_payload := (
        payload >payload_start $payload_byte_received
    );

    # instantiate machine rules
    main := (
        (startflag $err(packet_err) @startflag_received)
        (header $err(packet_err) @{ fcall process_payload; } %payload_end)
        (crc $err(packet_err) >crc_start @crc_received)?
        (endflag $err(packet_err) @endflag_received)
    );
}%%