#pragma rtGlobals=1		// Use modern global access method.

#ifndef IGORUNIT_UTILS
#define IGORUNIT_UTILS

Constant TRUE = 1
Constant FALSE = 0

Function printTestResult(curr_fn_name, status)
    String curr_fn_name
    Variable status

    print curr_fn_name
    if (status == TRUE)
        print "OK\r"
    else
        print "FAIL\r"
    endif
End

Function/S discoverTests()
    return FunctionList("test*", ";", "KIND:2")
End

// Stub for function references
Function prototest()
End

#endif