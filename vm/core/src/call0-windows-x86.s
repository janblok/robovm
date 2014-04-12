/*
 * Copyright (C) 2012 Trillian AB
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
functionOffset       = 0  # void*
stackArgsSizeOffset  = 4  # jint
stackArgsIndexOffset = 8  # jint
stackArgsOffset      = 12 # void**
returnValueOffset    = 16 # FpIntValue
returnTypeOffset     = 24 # jint
CallInfoSize         = 28

    .text

    .globl __call0
    
    .align    16, 0x90

    .def    __call0; .scl    2;      .type   32;
    .endef

__call0:
.Lcall0Begin:
    push  %ebp
    mov   %esp, %ebp
    mov   8(%ebp), %eax         # %eax = First arg (CallInfo*)

    mov   stackArgsSizeOffset(%eax), %ecx # %ecx = stackArgsSize
.LsetStackArgsNext:
    test  %ecx, %ecx
    je    .LsetStackArgsDone
    dec   %ecx
    mov   stackArgsOffset(%eax), %edx     # %edx = stackArgs
    lea   (%edx, %ecx, 4), %edx  # %edx = stackArgs + %ecx * 4
    push  (%edx)
    jmp   .LsetStackArgsNext
.LsetStackArgsDone:

    call  *functionOffset(%eax)

    leave
    ret

.Lcall0End:
