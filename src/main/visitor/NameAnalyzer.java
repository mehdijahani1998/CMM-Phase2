package main.visitor;

import main.ast.nodes.Program;
import main.ast.nodes.declaration.FunctionDeclaration;
import main.ast.nodes.declaration.MainDeclaration;
import main.ast.nodes.declaration.VariableDeclaration;
import main.ast.nodes.expression.*;
//import main.ast.nodes.expression.values.ListValue;
//import main.ast.nodes.expression.values.VoidValue;
import main.ast.nodes.expression.values.primitive.BoolValue;
import main.ast.nodes.expression.values.primitive.IntValue;
//import main.ast.nodes.expression.values.primitive.StringValue;
import main.ast.nodes.statement.*;
//import main.compileErrors.nameErrors.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.exceptions.ItemNotFoundException;
import main.symbolTable.items.FunctionSymbolTableItem;

import java.util.ArrayList;
import main.symbolTable.items.*;
import java.util.*;


public class NameAnalyzer extends Visitor<Void> {
    public boolean hasError = false;
    public static Stack<SymbolTable> naStack = new Stack<>();

    @Override
    public Void visit(Program program) {

        SymbolTable.root = new SymbolTable();
        naStack.push(SymbolTable.root);
        // first trying to add all possible functions to root
        for (FunctionDeclaration funcDec : program.getFunctions()) {
            FunctionSymbolTableItem fsti = new FunctionSymbolTableItem(funcDec);

            SymbolTable funcSymTab = new SymbolTable();
            ArrayList<VariableDeclaration> args = funcDec.getArgs();
            for (VariableDeclaration curId : args) {
                VariableSymbolTableItem vsti = new VariableSymbolTableItem(curId.getVarName());
                try {
                    funcSymTab.put(vsti);
                } catch (ItemAlreadyExistsException ignore) {
                }
            }

            fsti.setFunctionSymbolTable(funcSymTab);

            try {
                SymbolTable.root.put(fsti);
            } catch (ItemAlreadyExistsException itemAlreadyExistsException) {
                String oldFuncName = funcDec.getFunctionName().getName();
                for (int i = 1; i < 1000; i++) {
                    String newFuncName = oldFuncName + "@" + String.valueOf(i);
                    try {
                        funcDec.setFunctionName(new Identifier(newFuncName));
                        FunctionSymbolTableItem newFsti = new FunctionSymbolTableItem(funcDec);
                        newFsti.setFunctionSymbolTable(funcSymTab);
                        SymbolTable.root.put(newFsti);
                        break;
                    } catch (ItemAlreadyExistsException ignored) {
                    }
                }
            }
        }

        program.getMain().accept(this);
        //f,g,h,f --> f,g,h,f@1 (included in SymbolTable.root)

        return null;
    }

    @Override
    public Void visit(FunctionDeclaration funcDeclaration) {
        // System.out.println("Arrived at function " + funcDeclaration.getFunctionName().getName());
        SymbolTableItem fsti = new FunctionSymbolTableItem(funcDeclaration);
        try {
            fsti = SymbolTable.root.getItem("Function_" + funcDeclaration.getFunctionName().getName());
        } catch (ItemNotFoundException ex) {
            System.exit(2);
        } // we know it won't happen

        FunctionDeclaration funcDec = funcDeclaration;
        naStack.push(((FunctionSymbolTableItem) (fsti)).getFunctionSymbolTable());

        ArrayList<VariableDeclaration> args = funcDec.getArgs();

        funcDec.getBody().accept(this);
        naStack.pop();
        return null;
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        if (mainDeclaration.getBody() != null)
            mainDeclaration.getBody().accept(this); //not sure
        return null;
    }


    @Override
    public Void visit(BlockStmt blockStmt) {
        for (Statement stmt : blockStmt.getStatements())
            stmt.accept(this);
        return null;
    }

    @Override
    public Void visit(ConditionalStmt conditionalStmt) {
        if (conditionalStmt.getCondition() != null)
            conditionalStmt.getCondition().accept(this);

        if (conditionalStmt.getThenBody() != null)
            conditionalStmt.getThenBody().accept(this);

        if (conditionalStmt.getElseBody() != null)
            conditionalStmt.getElseBody().accept(this);

        return null;
    }

    @Override
    public Void visit(FunctionCallStmt funcCallStmt) {
        if (funcCallStmt.getFunctionCall() != null)
            funcCallStmt.getFunctionCall().accept(this);
        return null;
    }

    @Override
    public Void visit(DisplayStmt display) {
        if (display.getArg() != null)
            display.getArg().accept(this);
        return null;
    }

    @Override
    public Void visit(ReturnStmt returnStmt) {
        if (returnStmt.getReturnedExpr() != null)
            returnStmt.getReturnedExpr().accept(this);
        return null;
    }

    @Override
    public Void visit(BinaryExpression binaryExpression) {
        if (binaryExpression.getBinaryOperator() != null)
            binaryExpression.getFirstOperand().accept(this);

        if (binaryExpression.getSecondOperand() != null)
            binaryExpression.getSecondOperand().accept(this);
        return null;
    }

    @Override
    public Void visit(UnaryExpression unaryExpression) {
        if (unaryExpression.getOperand() != null)
            unaryExpression.getOperand().accept(this);
        return null;
    }

    @Override
    public Void visit(Identifier identifier) {
//        System.out.println("Arrived at Identifier " + identifier.getName());
        boolean flag1 = false, flag2 = false;
        if (naStack.peek() == null)
            System.exit(2);
        try {
            naStack.peek().getItem("Var_" + identifier.getName());
        } catch (ItemNotFoundException ex) {
            flag1 = true;
        }

        try {
            SymbolTable.root.getItem("Function_" + identifier.getName());
        } catch (ItemNotFoundException ex) {
            flag2 = true;
        }

        return null;
    }

    @Override
    public Void visit(ListAccessByIndex listAccessByIndex) {
        if (listAccessByIndex.getInstance() != null)
            listAccessByIndex.getInstance().accept(this);

        if (listAccessByIndex.getIndex() != null)
            listAccessByIndex.getIndex().accept(this);
        return null;
    }

    @Override
    public Void visit(ListSize listSize) {

        if (listSize.getArg() != null)
            listSize.getArg().accept(this);
        return null;
    }

    @Override
    public Void visit(FunctionCall funcCall) {
        Expression funcInst = funcCall.getInstance();
        boolean isIdentifier = false;

        boolean isFunction = true, isFuncPtr = true;
        // System.out.println("func inst is: " + funcInst.toString());
        if (funcInst.toString().contains("Identifier_")) {
            String funcName = ((Identifier) funcInst).getName();
            try {
                SymbolTable.root.getItem("Function_" + funcName);
                isIdentifier = true;
            } catch (ItemNotFoundException ex) {
                isFunction = false;
            }

            try {
                naStack.peek().getItem("Var_" + funcName);
                isIdentifier = true;
            } catch (ItemNotFoundException ex) {
                isFuncPtr = false;
            }
        }

        if (!funcCall.getInstance().toString().contains("Identifier_"))
            funcCall.getInstance().accept(this);

        if (funcCall.getArgs() != null)
            for (Expression e : funcCall.getArgs())
                e.accept(this);
        return null;
    }



    public Void visit(IntValue intValue) {

        return null;
    }


    public Void visit(BoolValue boolValue) {

        return null;
    }
}
