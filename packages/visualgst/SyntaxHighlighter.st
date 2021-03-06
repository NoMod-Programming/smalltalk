"======================================================================
|
| SyntaxHighlighter class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

STInST.STInST.RBProgramNodeVisitor subclass: SyntaxHighlighter [
    | textBuffer variable |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    SyntaxHighlighter class >> highlight: node in: aGtkTextBuffer [
	<category: 'instance creation'>

	(self new)
	    initialize;
	    textBuffer: aGtkTextBuffer;
	    visitNode: node;
	    acceptComments: node comments
    ]

    initialize [
	<category: 'initialize-release'>

	variable := Dictionary new.
	variable
	    at: 'self' put: #specialId;
	    at: 'super' put: #specialId;
	    at: 'thisContext' put: #specialId
    ]

    textBuffer: aGtkTextBuffer [
	<category: 'initialize-release'>

	textBuffer := aGtkTextBuffer
    ]

    acceptComments: anArray [
	<category: 'visitor-double dispatching'>

	anArray ifNil: [ ^ self ].
	anArray do: [ :each |
	    textBuffer applyTagByName: #comment startOffset: (each first - 1) endOffset: each last ]
    ]

    acceptArrayNode: anArrayNode [
	<category: 'visitor-double dispatching'>

	self visitNode: anArrayNode body
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>

	self acceptVariableNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>

	aBlockNode colons with: aBlockNode arguments
	    do: [ :colonPos :argument | 
		self highlightNewVariable: argument as: #arguments ].

	self visitNode: aBlockNode body
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>

	| n |
	n := 0.
	self visitNode: aCascadeNode messages first receiver.
	aCascadeNode messages do: [ :each | 
		self highlightMessageSend: each ]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>

	textBuffer applyTagByName: #literal startOffset: (aLiteralNode start - 1) endOffset: aLiteralNode stop
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>

	self visitNode: aMessageNode receiver.
	self highlightMessageSend: aMessageNode
    ]

    acceptMethodNode: aMethodNode [
	"A pity we cannot share this code with highlightMessageSend: ..."

	<category: 'visitor-double dispatching'>

	aMethodNode isUnary 
	    ifTrue: 
		[ textBuffer applyTagByName: #unaryMsg startOffset: (aMethodNode selectorParts first start - 1) endOffset: aMethodNode selectorParts first stop ].
	aMethodNode isBinary 
	    ifTrue: 
		[ textBuffer applyTagByName: #binaryMsg startOffset: (aMethodNode selectorParts first start - 1) endOffset: aMethodNode selectorParts first stop.
		self highlightNewVariable: aMethodNode arguments first as: #arguments ].
	aMethodNode isKeyword 
	    ifTrue: 
		[ aMethodNode selectorParts with: aMethodNode arguments
		    do: [ :sel :arg | 
			textBuffer applyTagByName: #binaryMsg startOffset: (sel start - 1) endOffset: sel stop.
			self highlightNewVariable: arg as: #arguments ] ].
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: aBlockNode [
	<category: 'visitor-double dispatching'>

	self visitNode: aBlockNode body
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>

	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>

	| n |
	n := 0.
	aSequenceNode temporaries do: [ :temporary | 
	    self highlightNewVariable: temporary as: #temporary].
	aSequenceNode statements do: [ :each |
	    self visitNode: each ]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>

	| tag |
	tag := variable at: aVariableNode name ifAbsentPut: [ #undeclaredVar ].
	textBuffer applyTagByName: tag startOffset: (aVariableNode start - 1) endOffset: aVariableNode stop
    ]

    highlightMessageSend: aMessageNode [
	<category: 'visitor-double dispatching'>

	aMessageNode isUnary 
	    ifTrue: 
		[ textBuffer applyTagByName: #unaryMsg startOffset: (aMessageNode selectorParts first start - 1) endOffset: aMessageNode selectorParts first stop ].
	aMessageNode isBinary 
	    ifTrue: 
		[ textBuffer applyTagByName: #binaryMsg startOffset: (aMessageNode selectorParts first start - 1) endOffset: aMessageNode selectorParts first stop.
		self visitNode: aMessageNode arguments first ].
	aMessageNode isKeyword
	    ifTrue: [
		aMessageNode selectorParts with: aMessageNode arguments
		    do: [ :sel :arg |
			textBuffer applyTagByName: #binaryMsg startOffset: (sel start - 1) endOffset: sel stop.
			self visitNode: arg ] ]
    ]

    highlightNewVariable: node as: kind [
	<category: 'visitor-double dispatching'>

	variable at: node name ifAbsentPut: [ kind ].
	textBuffer applyTagByName: kind startOffset: (node start - 1) endOffset: node stop
    ]
]

