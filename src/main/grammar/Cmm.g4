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
    $programRet.addStruct($sD.programRet);}
    )*
    (fD = functionDeclaration {
    $programRet.addFunction($fD.programRet);}
    )*
    m = main {
    $programRet.setMain($m.programRet);};

//todo
main returns[MainDeclaration mainRet]:
    {$mainRet = new MainDeclaration();}
    mn = MAIN {
    mainRet.setLine($mn.getLine());}
    LPAR RPAR
    bd = body {
    $mainRet.setBody($bd.mainRet)};

//todo
structDeclaration returns[StructDeclaration ret]:
    {$ret = new StructDeclaration();}
    st = STRUCT id = identifier {
    $ret.setLine($st.getLine());
    $ret.setStructName($id.ret);}
    ((bg = BEGIN sB = structBody {
    $sB.ret.setLine($bg.getLine());
    $ret.setBody($sB.ret);}
    NEWLINE+ END)
    |
    (NEWLINE+ sS = singleStatementStructBody {
    $ret.setBody($sS.ret);} SEMICOLON?))
    NEWLINE+;

//todo
singleVarWithGetAndSet returns[SetGetVarDeclaration sgret]:
    {$sgret = new SetGetVarDeclaration();}
    ty = type {
    $sgret.setVarType($ty.sgret);}

    id = identifier {
    $sgret.setLine($id.sgret.getLine());
    $sgret.setVarName($id.sgret);}

    fAD = functionArgsDec {
    $sgret.setArgs($fAD.sgret);} BEGIN NEWLINE+

    sB = setBody {
    $sgrett.setSetterBody($sB.sgret);}

    gB = getBody {
    $sgret.setGetterBody($gB.sgret);} END;

//todo
singleStatementStructBody returns[Statement stret]:
    (vd = varDecStatement {$stret = $vd.stret;})
    | (sv = singleVarWithGetAndSet {$stret = $sv.stret;});

//todo
structBody returns[BlockStmt bsret]:
    {$bsret = new BlockStmt();}
    (NEWLINE+

    (sSt = singleStatementStructBody {
    $bsret.addStatement($sSt.bsret);} SEMICOLON)*

    sSt = singleStatementStructBody {
    $bsret.addStatement($sSt.bsret);} SEMICOLON?)+;

//todo
getBody returns[Statement stret]:
    GET bd = body {
    $stret = $bd.stret;} NEWLINE+;

//todo
setBody returns[Statement stret]:
    SET bd = body {
    $stret = $bd.stret;} NEWLINE+;

//todo
functionDeclaration returns[FunctionDeclaration fdret]:
    {$fdret = new FunctionDeclaration();}
    (ty = type {
    $fdret.setReturnType($ty.fdret);} |

    vd = VOID {
    $fdret.setReturnType(new VoidType());})

    id = identifier {
    $fdret.setLine($id.fdret.getLine());
    $fdret.setFunctionName($id.fdret);}

    fAD = functionArgsDec {
    $fdret.setArgs($fAD.fdret);}

    b = body {
    $fdret.setBody($b.fdret);}
    NEWLINE+;

//todo
functionArgsDec returns[ArrayList<VariableDeclaration> lret]:
    {$lret = new ArrayList<VariableDeclaration>();}

    LPAR (
    (ty = type id = identifier {
    $VariableDeclaration vD = new VariableDeclaration($id.lret,$ty.lret);
    $vD.setLine($id.lret.getLine());
    $lret.add($vD)})

    (COMMA ty = type id = identifier {
    VariableDeclaration vD = new VariableDeclaration($id.lret,$ty.lret);
    vD.setLine($id.lret.getLine());
    $lret.add(vD)})*

    )? RPAR ;

//todo
functionArguments returns[ArrayList<Expression> listOfArgsRet]:
    {$listOfArgsRet = new ArrayList<Expression>();}

    ((exp = expression {
    $listOfArgsRet.add($exp.listOfArgsRet);})

    (COMMA exp = expression {
    $listOfArgsRet.add($exp.listOfArgsRet);})*)?;

//todo
body returns[Statement statementRet]:
     ((bS = blockStatement {
     $statementRet = $bS.statementRet;})
     | (NEWLINE+ sS = singleStatement {
     $statementRet = $sS.statementRet;} (SEMICOLON)?));

//todo
loopCondBody  returns [Statement sRet]:
     (bS = blockStatement {
     $sRet = $bS.sRet;
     } | (NEWLINE+ sS = singleStatement {
     $statementRet = $sS.sRet;
     }));

//todo
blockStatement returns [BlockStmt bRet]:
    {$bRet = new BlockStmt();}

    bg = BEGIN {
    $bRet.setLine($bg.bRet.getline())}
    (NEWLINE+ (st = singleStatement {
    $bRet.addStatement($st.bRet);}
    SEMICOLON)* singleStatement (SEMICOLON)?)+ NEWLINE+ END;

//todo
varDecStatement returns [VarDecStmt vret]:
    {$ArrayList<VariableDeclaration> vretArray = new ArrayList<VariableDeclaration>();}

    ty = type id = identifier{
    int line_num = $id.vret.getLine();}
    (ASSIGN oxp = orExpression {
    VariableDeclaration vd = new VariableDeclaration ($id,vret, $ty.vret);
    vd.setLine(line_num);
    vd.setDefaultValue($oxp.vret);
    vretArray.add(vd);
    })?

    (COMMA id2 = identifier (ASSIGN oxp2 = orExpression {
    VariableDeclaration vd = new VariableDeclaration($id2.vret,$ty.vret);
    vd.setLine(line_num);
    vd.setDefaultValue($oxp2.vret);
    vretArray.add(vd);
    })? )*;

//todo
functionCallStmt  returns [FunctionCallStmt fcret]:

     oxp = otherExpression
     {FunctionCall fcall = new FunctionCall($oxp.fcret);}
     ((l1 = LPAR farg = functionArguments {
     fcall.setInstance($oxp.fcret);
     fcall.setArgs($farg.fcret);
     fcall.setLine($l1.getLine());}  RPAR) |

     (dt = DOT id = identifier))* (l2 = LPAR farg2 = functionArguments {
     $StructAccess sac = new StructAccess($oxp.fcret, $id.fcret);
     sac.setLine($dt.getLine());
     fcall.setInstance(sac);
     fcall.setArgs($farg2.fcret);
     fcall.setLine($l2.fcret)
     } RPAR)
     {$fcret = new FunctionCallStmt(fcall);}
     ;

//todo
returnStatement returns [ReturnStmt returnStmtRet]:
    {$returnStmtRet = new ReturnStmt();}
    RETURN (exp = expression {
    $returnStmtRet.setReturnedExpr($exp.returnStmtRet);
    })?;

//todo
ifStatement returns [ConditionalStmt conditionalStmtRet]:
    if = IF exp = expression {
    $conditionalStmtRet = new conditionalStmt($exp.conditionalStmtRet);
    $conditionalStmtRet.setLine($if.getLine())
    }
    (lcb = loopCondBody {
    $conditionalStmtRet.setThenBody($lcb.conditionalStmtRet);
    }
    | bd = body els = elseStatement {
    $conditionalStmtRet.setThenBody($bd.conditionalStmtRet);
    $conditionalStmtRet.setElseBody($els.conditionalStmtRet);
    });

//todo
elseStatement returns [Statement statementRet]:
     NEWLINE* ELSE lcb = loopCondBody {$statementRet = $lcb.statementRet;};

//todo
loopStatement returns [LoopStmt loopStmtRet]:
  (wls =  whileLoopStatement {
  $loopStmtRet = $wls.loopStmtRet;})|
  (dwl = doWhileLoopStatement {
  $loopStmtRet = $dwl.loopStmtRet;});

//todo
whileLoopStatement returns [LoopStmt lsret]:
    wl = WHILE exp = expression lcb = loopCondBody{
        $lsret = new LoopStmt();
        $lsret.setCondition($exp.lsret);
        $lsret.setBody($lcb.lsret);
        $lsret.setLine($wl.getLine());
    };

//todo
doWhileLoopStatement returns [LoopStmt lsret]:
    do = DO bd = body NEWLINE* WHILE sxp = expression{
          $lsret = new LoopStmt();
          $lsret.setCondition($exp.lsret);
          $lsret.setBody($bd.lsret);
          $lsret.setLine($do.getLine());
    };

//todo
displayStatement returns [DisplayStmtdsret]:
  dsp = DISPLAY LPAR exp = expression RPAR {
    $dsret = new DisplayStmt)($exp.dsret);
    $dsret.setLine($dsp.getLine());
  };

//todo
assignmentStatement returns [AssignmentStmt asret]:
    oxp = orExpression asg = ASSIGN exp = expression {
    $asret = new AssignmentStmt($oxp.asret, $lxp.asret);
    $asret.setLine($asg.getLine());
    };

//todo
singleStatement returns [Statement sret]:

    (ifs = ifStatement {$sret = $ifs.sret;})|
    (dst = displayStatement {$sret = $dst.sret;})|
    (fcs = functionCallStmt {$statementRet = $fcs.sret;})|
    (rst = returnStatement {$statementRet = $rst.sret;})|
    (ass = assignmentStatement {$statementRet = $ass.sret;}) |
    (vds = varDecStatement {$statementRet = $vds.sret}) |
    (ls = loopStatement {$statementRet = $ls.sret})|
    (ap = append {$sret = new ListAppendStmt ($ap.sret)})|
    (s = size {
    $sret = new ListSizeStmt ($s,sret);
    $sret.setLine($s.sret.getLine());
    });

//todo
expression returns [Expression exret]:
    oxp = orExpression {$exret = $oxp.exret}
    (op = ASSIGN exp = expression {
    $exret = new BinaryExpression($oxp.exret, $exp.exret, BinaryOperator.assign);
    $exret.setLine($op.getLine());
    })? ;

//todo
orExpression returns[Expression exret]:
    axp = andExpression {$exret = $axp.exret;}
    (op = OR axp2 = andExpression {
    $exret = new BinaryExpression($exret, $axp2.exret, BinaryOperator.or);
    $exret.setLine($op.getLine());
    })*;

//todo
andExpression returns [Expression exret]:
    eql = equalityExpression {$exret = $eql.ret;}
        (op = AND eql2 = equalityExpression {
            $exret = new BinaryExpression($exret, $eql2.exret, BinaryOperator.and);
            $exret.setLine($op.getLine());
        })*;

//todo
equalityExpression returns [Expression exret]:
        rxp = relationalExpression {$exret = $rxp.exret;}
        (op = EQUAL rxp2 = relationalExpression {
            $exret = new BinaryExpression($exret, $rxp2.exret, BinaryOperator.eq);
            $exret.setLine($op.getLine());
        })*;
//todo
relationalExpression returns [Expression exret]:
    adx = additiveExpression {$exret = $adx.exret;}
        {BinaryOperator bp;}
        ((op = GREATER_THAN {bp = BinaryOperator.gt;}
        | op = LESS_THAN {bp = BinaryOperator.lt;}) adx2 = additiveExpression {
            $exret = new BinaryExpression($exret, $adx2.exret, bp);
            $exret.setLine($op.getLine());
        })*;
//todo

additiveExpression returns[Expression exret]:
        mux = multiplicativeExpression {$exret = $mux.exret;}
        {BinaryOperator bp;}
        ((op = PLUS {bp = BinaryOperator.add;}
        | op = MINUS {bp = BinaryOperator.sub;}) mux2 = multiplicativeExpression {
        $exret = new BinaryExpression($exret, $mux2.exret, bp);
        $exret.setLine($op.getLine());
        })*;
//todo
multiplicativeExpression returns[Expression exret]:
    prex = preUnaryExpression {$exret = $prex.exret;}
        {BinaryOperator bp;}
        ((op = MULT {bp = BinaryOperator.mult;}
        | op = DIVIDE {bp = BinaryOperator.div;}) prex2 = preUnaryExpression {
            $exret = new BinaryExpression($exret, $prex2.exret, bp);
            $exret.setLine($op.getLine());
        })*;
//todo
preUnaryExpression returns [Expression exret]:
    {UnaryOperator up;}
        ((op = NOT {up = UnaryOperator.not;}
        | op = MINUS {up = UnaryOperator.minus;}) prex = preUnaryExpression {
            $exret = new UnaryExpression($prex.ret, up);
            $exret.setLine($op.getLine());
        })
        | (acx = accessExpression {
        $exret = $acx.exret;});

//todo
accessExpression returns [Expression expressionRet]:
    oxp = otherExpression {$expressionRet = $oxp.expressionRet}
    ((lpar = LPAR farg = functionArguments RPAR) {
    $expressionRet = new FunctionCall($expressionRet, $farg.expressionRet);
    $expressionRet.setLine($lpar.getline());}
    | (dot = DOT id = identifier {
    $expressionRet = new StructAccess($expressionRet, $id.expressionRet);
    $expressionRet.setLine($dot.getline());
    }))*
    ((lbr = LBRACK exp = expression {
    $expressionRet = new ListAccessByIndex($expressionRet, $exp.expressionRet);
    $expressionRet.setLine($lbr.getLine());
    } RBRACK)
    | (dot2 = DOT id2 = identifier {
    $expressionRet = new StructAccess($expressionRet, $id2.expressionRet);
    expressionRet.setLine($dot2.getline());
    }))*;

//todo
otherExpression returns [Expression exret]:
    (val = value {$exret = $val.exret;})
    | (id = identifier {$exret = $id.exret;})
    | lpar = LPAR (farg = functionArguments) RPAR {
    $exret = new ExprInPar($farg.exret);
    $exret.setLine($lpar.getLine());}
    | (sz = size {$exret = $sz.exret;})
    | (ap = append {$exret = $ap.exret;});

//todo
size returns [ListSize lsret]:
    sz = SIZE LPAR exp = expression RPAR {
    $lsret = new ListSize($exp.lsret);
    $lsret.setLine($sz.getLine());
    };

//todo
append returns [ListAppend lAppRet]:

    app = APPEND LPAR exp = expression COMMA exp2 = expression RPAR{
    $lAppRet = new ListAppend($exp.lAppRet, $exp2.lAppRet);
    $lAppRet.setLine($app.getLine());
    };

//todo
value returns [Value valueRet]:

    (bv = boolValue {$valueRet = $bv.valueRet;})
    | (iv = INT_VALUE {
    $valueRet = new IntValue( Integer.valueOf ($iv.text).intValue());});

//todo
boolValue returns [BoolValue boolValueRet]:

    (t = TRUE {
    $boolValueRet = new BoolValue(true);
    $boolValueRet.setLine($t.getLine());
    })
    | (f = FALSE {
    $boolValueRet = new BoolValue(false);
    $boolValueRet.setLine($f.getLine());
    });

//todo
identifier returns [Identifier iret]:
    (id = IDENTIFIER {
    $iret = new Identifier($id.text);
    $iret.setLine($id.getLine());
    });

//todo
type returns [Type typeRet]:
    (INT {$typeRet = new IntType();})
    | (BOOL {$typeRet = new BoolType();})
    | (LIST SHARP ty = type {$typeRet = new ListType($ty.typeRet);})
    | (STRUCT id = identifier {$typeRet = new StructType($id.typeRet);})
    | (ft = fptrType {$typeRet = $ft.typeRet;});

//todo
fptrType returns [FptrType ftret]:
    {$ftret = new FptrType(new ArrayList<Type>(), new VoidType());}
        FPTR LESS_THAN ((VOID {
        $ftret.addArgType(new VoidType());})
        | (ty = type {
        $ftret.addArgType($ty.ftret);}
        (COMMA ty2 = type {
        $ftret.addArgType($ty2.ftret);})*))
        ARROW (ty3 = type {
        $ftret.setReturnType($ty3.ftret);}
        | (VOID {
        $ftret.setReturnType(new VoidType());})) GREATER_THAN;
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