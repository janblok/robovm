/*
 * Copyright (C) 2012 Trillian AB
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/gpl-2.0.html>.
 */
package org.robovm.compiler.llvm;


/**
 *
 * @version $Id$
 */
public class FunctionDeclaration {
    private final String name;
    private final Linkage linkage;
    private final FunctionType type;

    public FunctionDeclaration(String name, FunctionType type) {
    	this(name,type,null);
    }
    
    public FunctionDeclaration(String name, FunctionType type,Linkage linkage) {
        this.name = name;
        this.linkage = linkage;
        this.type = type;
    }

    public FunctionDeclaration(FunctionRef ref) {
        this(ref.getName(), ref.getType());
    }

    public FunctionDeclaration(Function f) {
        this(f.getName(), f.getType(), f.getLinkage());
    }

    public String getName() {
        return name;
    }

    public Linkage getLinkage() {
        return linkage;
    }

    public FunctionType getType() {
        return type;
    }
    
    public FunctionRef ref() {
        return new FunctionRef(name, type);
    }
    
    @Override
    public String toString() {
        Type returnType = type.getReturnType();
        Type[] parameterTypes = type.getParameterTypes();
        StringBuilder sb = new StringBuilder();
        sb.append("declare ");
        if (linkage != null) {
            sb.append(linkage);
            sb.append(' ');
        }
        sb.append(returnType.toString());
        sb.append(" @");
        sb.append(name);
        sb.append('(');
        for (int i = 0; i < parameterTypes.length; i++) {
            if (type.isVarargs() || i > 0) {
                sb.append(", ");
            }
            sb.append(parameterTypes[i].toString());
        }
        if (type.isVarargs()) {
            sb.append("...");
        }
        sb.append(")");
        return sb.toString();
    }
}
