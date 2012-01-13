#pragma rtGlobals=1		// Use modern global access method.

// TestSuite -- a component of IgorUnit
//   This data type can be used to organize tests into sets/suites

#ifndef IGORUNIT_TS
#define IGORUNIT_TS

#include "booleanutils"
#include "listutils"
#include "waveutils"
#include "datafolderutils"

#include "UnitTest"

Structure TestSuite
    String groups
    Wave/T tests
    Wave/T testfuncs
    Variable test_no
EndStructure

Function TS_persist(ts, to_dfpath)
    STRUCT TestSuite &ts
    String to_dfpath
    
    DFREF to_dfref = DataFolder_create(to_dfpath)
    String/G to_dfref:groups = ts.groups
    MoveWave ts.tests, to_dfref:tests
    MoveWave ts.testfuncs, to_dfref:testfuncs
    Variable/G to_dfref:test_no = ts.test_no
End

Function TS_load(ts, from_dfpath)
    STRUCT TestSuite &ts
    String from_dfpath
    
    DFREF from_dfref = DataFolder_getDFRfromPath(from_dfpath)
    SVAR groups = from_dfref:groups
    NVAR test_no = from_dfref:test_no

    Wave/T ts.tests = from_dfref:tests
    Wave/T ts.testfuncs = from_dfref:testfuncs

    ts.groups = groups
    ts.test_no = test_no

    KillDataFolder from_dfref
End

Function TS_init(ts)
    STRUCT TestSuite &ts
    ts.test_no = 0
    ts.groups = ""
    Make/FREE/T/N=0 ts.tests
    Make/FREE/T/N=0 ts.testfuncs
End

Function TS_addGroup(ts, groupname)
    STRUCT TestSuite &ts
    String groupname

    if (!TS_hasGroup(ts, groupname))
        ts.groups = AddListItem(groupname, ts.groups, ";", Inf)
        TS_initNewGroupTestList(ts)
    endif
    return TS_getGroupIndex(ts, groupname)
End

Static Function TS_initNewGroupTestList(ts)
    STRUCT TestSuite &ts
    Variable group_count = TS_getGroupCount(ts)

    Wave_appendRow(ts.tests)
    ts.tests[Inf] = ""

    Wave_appendRow(ts.testfuncs)
    ts.testfuncs[Inf] = ""
End

Function TS_addTest(ts, test)
    STRUCT TestSuite &ts
    STRUCT UnitTest &test

    Variable group_idx = TS_addGroup(ts, test.groupname)
    if (!TS_hasTest(ts, test.groupname, test.testname))
        ts.tests[group_idx] = AddListItem(test.testname, ts.tests[group_idx], ";", Inf)
        ts.testfuncs[group_idx] = AddListItem(test.funcname, ts.testfuncs[group_idx], ";", Inf)
        ts.test_no += 1
    endif
    return TS_getTestIndex(ts, test.groupname, test.testname)
End

Function TS_addTestByName(ts, groupname, testname, funcname)
    STRUCT TestSuite &ts
    String groupname, testname, funcname

    STRUCT UnitTest test
    UnitTest_init(test, groupname, testname, funcname)
    return TS_addTest(ts, test)
End

// Load UnitTest into output_test
Function TS_getTest(ts, groupname, testname, output_test)
    STRUCT TestSuite &ts
    String groupname, testname
    STRUCT UnitTest &output_test

    String funcname = TS_getTestFuncName(ts, groupname, testname)
    UnitTest_set(output_test, groupname, testname, funcname)
End

Function TS_removeTest(ts, groupname, testname)
    STRUCT TestSuite &ts
    String groupname, testname

    Variable group_idx = TS_getGroupIndex(ts, groupname)
    if (TS_hasTest(ts, groupname, testname))
        Variable test_idx = TS_getTestIndex(ts, groupname, testname)
        ts.tests[group_idx] = RemoveListItem(test_idx, ts.tests[group_idx], ";")
        ts.test_no -= 1
    endif
End

Function/S TS_getGroupByIndex(ts, group_idx)
    STRUCT TestSuite &ts
    Variable group_idx

    String groupname = StringFromList(group_idx, ts.groups)
    return groupname
End

Function/S TS_getTestByIndex(ts, group_idx, test_idx)
    STRUCT TestSuite &ts
    Variable group_idx, test_idx

    String test_list = TS_getGroupTestsByIndex(ts, group_idx)
    String testname = StringFromList(test_idx, test_list)
    return testname
End

Function/S TS_getGroupTests(ts, groupname)
    // Return a list of tests in a given group
    STRUCT TestSuite &ts
    String groupname

    Variable group_idx = TS_getGroupIndex(ts, groupname)
    return TS_getGroupTestsByIndex(ts, group_idx)
End

Function/S TS_getGroupTestsByIndex(ts, group_idx)
    // Return a list of tests in a given group
    STRUCT TestSuite &ts
    Variable group_idx

    return ts.tests[group_idx]
End

Function/S TS_getGroupTestFuncs(ts, groupname)
    // Return a list of test functions in a given group
    STRUCT TestSuite &ts
    String groupname

    Variable group_idx = TS_getGroupIndex(ts, groupname)
    return TS_getGroupFuncsByIndex(ts, group_idx)
End

Function/S TS_getGroupFuncsByIndex(ts, group_idx)
    // Return a list of test functions in a given group
    STRUCT TestSuite &ts
    Variable group_idx

    return ts.testfuncs[group_idx]
End

Function TS_getGroupTestCount(ts, groupname)
    STRUCT TestSuite &ts
    String groupname

    String test_list = TS_getGroupTests(ts, groupname)
    return List_getLength(test_list)
End

Function TS_hasGroup(ts, groupname)
    STRUCT TestSuite &ts
    String groupname

    if (TS_getGroupIndex(ts, groupname) > -1)
        return TRUE
    endif
    return FALSE
End

Function TS_hasTest(ts, groupname, testname)
    STRUCT TestSuite &ts
    String groupname, testname

    if (TS_getTestIndex(ts, groupname, testname) > -1)
        return TRUE
    endif
    return FALSE
End

Function TS_getGroupIndex(ts, groupname)
    STRUCT TestSuite &ts
    String groupname

    return WhichListItem(groupname, ts.groups, ";")
End

Function TS_getTestIndex(ts, groupname, testname)
    STRUCT TestSuite &ts
    String groupname, testname

    String test_list = TS_getGroupTests(ts, groupname)
    return WhichListItem(testname, test_list, ";")
End

Function/S TS_getTestFuncName(ts, groupname, testname)
    STRUCT TestSuite &ts
    String groupname, testname

    Variable test_idx = TS_getTestIndex(ts, groupname, testname)
    String func_list = TS_getGroupTestFuncs(ts, groupname)
    return StringFromList(test_idx, func_list)
End

Function TS_getTestCount(ts)
    STRUCT TestSuite &ts
    return ts.test_no
End

Function TS_getGroupCount(ts)
    STRUCT TestSuite &ts
    return List_getLength(ts.groups)
End

#endif
