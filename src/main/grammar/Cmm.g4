grammar Cmm;

@header{
     import main.ast.nodes.*;
     import main.ast.nodes.declaration.*;
     import main.ast.nodes.declaration.struct.*;
     import main.ast.nodes.expression.*;
     import main.ast.nodes.expression.operators.*;
     import main.ast.nodes.expression.values.*;
     import main.ast.nodes.expression.values.primitive.*;
     import main.ast.nodes.statement.*;
     import main.ast.types.*;
     import main.ast.types.primitives.*;
     import java.util.*;
 }


cmm returns[Program cmmProgram]:
    NEWLINE* p = program {$cmmProgram = $p.programRet;} NEWLINE* EOF;

program returns[Program programRet]:
    {$programRet = new Program();
     int line = 1;
     $programRet.setLine(line);}

    (sD = structDeclaration {
    $programRet.addStruct($sD.structDeclarationRet);}
    )*
    (fD = functionDeclaration {
    $programRet.addFunction($fD.functionDeclarationRet);}
    )*
    m = main {
    $programRet.setMain($m.mainRet);};

//todo
main returns[MainDeclaration mainRet]:
    {$mainRet = new MainDeclaration();}
    mn = MAIN {
    mainRet.setLine($mn.getLine());}
    LPAR RPAR
    bd = body {
    $mainRet.setBody($bd)};

//todo
structDeclaration returns[StructDeclaration structDeclarationRet]:
    {$structDeclarationRet = new StructDeclaration();}
    st = STRUCT id = identifier {
    $structDeclarationRet.setLine($st.getLine());
    $structDeclarationRet.setStructName($id);}
    ((bg = BEGIN sB = structBody {
    $sB.setLine($bg.getLine());$structDeclarationRet.setBody($sB);}
    NEWLINE+ END)
    |
    (NEWLINE+ sS = singleStatementStructBody {$structDeclarationRet.setBody($sS);} SEMICOLON?))
    NEWLINE+;

//todo
singleVarWithGetAndSet returns[SetGetVarDeclaration setGetVarDeclarationRet]:
    {$setGetVarDeclarationRet = new SetGetVarDeclaration();}
    ty = type {
    $setGetVarDeclarationRet.getVarType($ty);}

    id = identifier {
    $setGetVarDeclarationRet.setLine($id.getLine());
    $setGetVarDeclarationRet.setVarName($id);}

    fAD = functionArgsDec {
    $setGetVarDeclarationRet.setArgs($fAD);} BEGIN NEWLINE+

    sB = setBody {
    $setGetVarDeclarationRet.setSetterBody($sB);}

    gB = getBody {
    $setGetVarDeclarationRet.setGetterBody($gB);} END;

//todo
singleStatementStructBody returns[Statement statementRent]:
    (v = varDecStatement {$statementRent = $v;})
    | (s = singleVarWithGetAndSet {$statementRent = $s;});

//todo
structBody returns[BlockStmt blockStmtRent]:
    {$blockStmtRent = new BlockStmt();}
    (NEWLINE+

    (sSt = singleStatementStructBody {
    $blockStmtRent.addStatement(sSt);} SEMICOLON)*

    sSt = singleStatementStructBody {
    $blockStmtRent.addStatement(sSt);} SEMICOLON?)+;

//todo
getBody returns[Statement statementRent]:
    GET bd = body {
    $statementRent = $b;} NEWLINE+;

//todo
setBody returns[Statement statementRent]:
    SET b = body {
    $statementRent = $b;} NEWLINE+;

//todo
functionDeclaration returns[FunctionDeclaration functionDeclarationRet]:
    {$functionDeclarationRet = new FunctionDeclaration();}
    (ty = type {
    $functionDeclarationRet.setReturnType($ty);} |

    vd = VOID {
    $functionDeclarationRet.setReturnType($vd);})

    id = identifier {
    $functionDeclarationRet.setLine($id.getLine());
    $functionDeclarationRet.setFunctionName($id);}

    fAD = functionArgsDec {
    $functionDeclarationRet.setArgs($fAD);}

    b = body {$functionDeclarationRet.setBody($b);}
    NEWLINE+;

//todo
functionArgsDec returns[ArrayList<VariableDeclaration> listOfArgsRet]:
    {$listOfArgsRet = new ArrayList<VariableDeclaration>();}

    LPAR (
    (ty = type id = identifier {
    $vD = new VariableDeclaration($id,$ty);
    $vD.setLine($id.getLine());
    $listOfArgsRet.add($vD)})

    (COMMA ty = type id = identifier {$vD = new VariableDeclaration($id,$ty);
    $vD.setLine($id.getLine());
    $listOfArgsRet.add($vD)})*

    )? RPAR ;

//todo
functionArguments returns[ArrayList<Expression> listOfArgsRet]:
    {$listOfArgsRet = new ArrayList<Expression>();}

    ((exp = expression {
    $listOfArgsRet.add($exp);})

    (COMMA exp = expression {
    $listOfArgsRet.add($exp);})*)?;

//todo
body returns[Statement statementRet]:
     ((bS = blockStatement {
     $statementRet = $bS;})
     | (NEWLINE+ sS = singleStatement {
     $statementRet = $sS;} (SEMICOLON)?));

//todo
loopCondBody  returns [Statement sRet]:
     (bS = blockStatement {
     $sRet = $bS;
     } | (NEWLINE+ sS = singleStatement {
     $statementRet = $sS;
     }));

//todo
blockStatement returns [BlockStmt blockStmtRet]:
    {$blockStmtRet = new BlockStmt();}

    bg = BEGIN {
    $blockStmtRet.setLine($bg.getline())}
    (NEWLINE+ (st = singleStatement {
    $blockStmtRet.addStatement($st);}
    SEMICOLON)* singleStatement (SEMICOLON)?)+ NEWLINE+ END;

//todo
varDecStatement returns [ArrayList<VariableDeclaration> variableDeclarationRetList]:
    {$variableDeclarationRetList = new ArrayList<VariableDeclaration>();}

    ty = type id = identifier{
    line_num = id.getLine();}
    (ASSIGN oxp = orExpression {
    $vd = new VariableDeclaration ($id, $ty);
    $vd.setLine(line_num);
    $vd.setDefaultValue($oxp);
    $variableDeclarationRetList.add($vd);
    })?

    (COMMA id2 = identifier (ASSIGN oxp2 = orExpression {
    $vd = new VariableDeclaration($id2,$ty);
    $vd.setLine($line_num);
    $vd.setDefaultValue($oxp2);
    $listOfVariableDeclarationRet.add($vd);
    })? )*;

//todo
functionCallStmt  returns [FunctionCallStmt functionCallStmtRet]:
    {$fcall = new FunctionCall();}
     oxp = otherExpression (
     (l1 = LPAR farg = functionArguments {
     $fcall.setInstance($oxp);
     $fcall.setArgs($farg);
     $fcall.setLine($l1.getLine());}  RPAR) |

     (dt = DOT id = identifier))* (l2 = LPAR farg2 = functionArguments {
     $sac = new StructAccess($oxp, $id);
     $sac.setLine($dt.getLine());
     $fcall.setInstance($sac);
     $fcall.setArgs($farg2);
     $fcall.setLine($)
     } RPAR);

//todo
returnStatement returns [ReturnStmt returnStmtRet]:
    {$returnStmtRet = new ReturnStmt();}
    RETURN (exp = expression {
    $returnStmtRet.setReturnedExpr($exp);
    })?;

//todo
ifStatement [ConditionalStmt conditionalStmtRet]:
    if = IF exp = expression {
    $conditionalStmtRet = new conditionalStmt($exp);
    $conditionalStmtRet.setLine($if.getLine())
    }
    (lcb = loopCondBody {
    $conditionalStmtRet.setThenBody($lcb);
    }
    | bd = body els = elseStatement {
    $conditionalStmtRet.setThenBody($bd);
    $conditionalStmtRet.setElseBody($els);
    });

//todo
elseStatement returns [Statement statementRet]:
     NEWLINE* ELSE lcb = loopCondBody {$statementRet = $lcb;};

//todo
loopStatement returns [LoopStmt loopStmtRet]:
  (wls =  whileLoopStatement {$loopStmtRet = $wls;})| (dwl = doWhileLoopStatement {$loopStmtRet = $dwl;});

//todo
whileLoopStatement returns [LoopStmt loopStmtRet]:
    wl = WHILE exp = expression lcb = loopCondBody{

    };

//todo
doWhileLoopStatement :
    DO body NEWLINE* WHILE expression;

//todo
displayStatement returns [DisplayStmt displayStmtRet]:
  dsp = DISPLAY LPAR exp = expression RPAR {
  $displayStmtRet = new DisplayStmt)($exp);
  $displayStmtRet.setLine($dsp.getLine());
  };

//todo
assignmentStatement returns [AssignmentStmt assignmentStmtRet]:
    oxp = orExpression asg = ASSIGN exp = expression {
    $assignmentStmtRet = new AssignmentStmt($oxp, $lxp);
    $assignmentStmtRet.setLine($asg.getLine());
    };

//todo
singleStatement returns [Statement statementRet]:

    (ifs = ifStatement {$statementRet = $ifs;})|
    (dst = displayStatement {$statementRet = $dst;})|
    (fcs = functionCallStmt {$statementRet = $fcs;})|
    (rst = returnStatement {$statementRet = $rst;})|
    (ass = assignmentStatement {$statementRet = $ass;}) |
    (vds = varDecStatement {$statementRet = $vds}) |
    (ls = loopStatement {$statementRet = $ls})|
    (ap = append {$statementRet=$ap})|
    (s = size {$statementRet=$s});

//todo
expression returns [Expression expressionRet]:
    oxp = orExpression {$expressionRet = $oxp}
    (op = ASSIGN exp = expression {
    $expressionRet = new BinaryExpression($oxp, $exp, $op);
    $expressionRet.setLine($op.getLine());
    })? ;

//todo
orExpression returns[Expression expressionRet]:
    axp = andExpression {$expressionRet = $axp;}
    (op = OR axp2 = andExpression {
    $expressionRet = new BinaryExpression($expressionRet, $axp2, $op);
    $expressionRet.setLine($op.getLine());
    })*;

//todo
andExpression returns [Expression expressionRet]:
    equalityExpression (op = AND equalityExpression )*;

//todo
equalityExpression:
    relationalExpression (op = EQUAL relationalExpression )*;

//todo
relationalExpression:
    additiveExpression ((op = GREATER_THAN | op = LESS_THAN) additiveExpression )*;

//todo
additiveExpression:
    multiplicativeExpression ((op = PLUS | op = MINUS) multiplicativeExpression )*;

//todo
multiplicativeExpression:
    preUnaryExpression ((op = MULT | op = DIVIDE) preUnaryExpression )*;

//todo
preUnaryExpression:
    ((op = NOT | op = MINUS) preUnaryExpression ) | accessExpression;

//todo
accessExpression returns [Expression expressionRet]:
    oxp = otherExpression {$expressionRet = $oxp}
    ((lpar = LPAR farg = functionArguments RPAR) {
    $expressionRet = new FunctionCall($expressionRet, $farg);
    expressionRet.setLine($lpar.getline());}
    | (dot = DOT id = identifier {
    $expressionRet = new StructAccess($expressionRet, $id);
    expressionRet.setLine($dot.getline());
    }))*
    ((lbr = LBRACK exp = expression {
    $expressionRet = new ListAccessByIndex($expressionRet, $exp);
    $expressionRet.setLine($lbr.getLine());
    } RBRACK)
    | (dot2 = DOT id2 = identifier {
    $expressionRet = new StructAccess($expressionRet, $id2);
    expressionRet.setLine($dot2.getline());
    }))*;

//todo
otherExpression returns [Expression expressionRet]:
    {$expressionRet = new Expression();}
    (val = value {$expressionRet = $val;})
    | (id = identifier {$expressionRet = $id;})
    | lpar = LPAR (farg = functionArguments) RPAR {
    $expressionRet = new ExprInPar($farg);
    $expressionRet.setLine($lpar.getLine());}
    | (sz = size {$expressionRet = $sz;})
    | (ap = append {$expressionRet = $ap;});

//todo
size returns [ListSize listSizeRet]:

    sz = SIZE LPAR exp = expression RPAR {
    $listSizeRet = new ListSize();
    $listSizeRet.setLine($sz.getLine());
    };

//todo
append returns [ListAppend lAppRet]:

    app = APPEND LPAR exp = expression COMMA exp2 = expression RPAR{
    $lAppRet = new ListAppend(exp, exp2);
    $lAppRet.setLine(app.getLine());
    };

//todo
value returns [Value valueRet]:

    (bv = boolValue {$valueRet = $bv;}) | (iv = INT_VALUE {$valueRet = $iv;});

//todo
boolValue returns [BoolValue boolValueRet]:

    (t = TRUE {
    $boolValueRet = new BoolValue($t);
    $boolValueRet.setLine($t.getLine());
    })
    | (f = FALSE {
    $boolValueRet = new BoolValue($f);
    $boolValueRet.setLine($f.getLine());
    });

//todo
identifier returns [Identifier identifierRet]:
    (id = IDENTIFIER {
    $identifierRet = new Identifier($id);
    $identifierRet.setLine($id.getLine());
    });

//todo
type returns [Type typeRet]:
    (INT {$typeRet = new IntType();})
    | (BOOL {$typeRet = new BoolType();})
    | (LIST SHARP ty = type {$typeRet = new ListType(ty);})
    | (STRUCT id = identifier {$typeRet = new StructType($id);})
    | (fptrType {$typeRet = $fptrType;});

//todo
fptrType returns [FptrType fTRet]:
    {fTRet = new FptrType();}
    FPTR LESS_THAN (VOID | (ty = type {$fTret.addArgType($ty);}
    (COMMA ty2 = type {$fTRet.addArgType($ty);})*))
    ARROW (ty3 = type {$fTRet.setReturnType($ty3);}| VOID) GREATER_THAN;

MAIN: 'main';
RETURN: 'return';
VOID: 'void';

SIZE: 'size';
DISPLAY: 'display';
APPEND: 'append';

IF: 'if';
ELSE: 'else';

PLUS: '+';
MINUS: '-';
MULT: '*';
DIVIDE: '/';


EQUAL: '==';
ARROW: '->';
GREATER_THAN: '>';
LESS_THAN: '<';


AND: '&';
OR: '|';
NOT: '~';

TRUE: 'true';
FALSE: 'false';

BEGIN: 'begin';
END: 'end';

INT: 'int';
BOOL: 'bool';
LIST: 'list';
STRUCT: 'struct';
FPTR: 'fptr';
GET: 'get';
SET: 'set';
WHILE: 'while';
DO: 'do';

ASSIGN: '=';
SHARP: '#';
LPAR: '(';
RPAR: ')';
LBRACK: '[';
RBRACK: ']';

COMMA: ',';
DOT: '.';
SEMICOLON: ';';
NEWLINE: '\n';

INT_VALUE: '0' | [1-9][0-9]*;
IDENTIFIER: [a-zA-Z_][A-Za-z0-9_]*;


COMMENT: ('/*' .*? '*/') -> skip;
WS: ([ \t\r]) -> skip;