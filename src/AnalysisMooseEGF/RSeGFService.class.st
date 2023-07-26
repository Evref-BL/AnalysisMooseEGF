Class {
	#name : #RSeGFService,
	#superclass : #Object,
	#instVars : [
		'eGFInvocationModel',
		'canvas'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
RSeGFService >> buildClassDependenciesCanvas [

	| ssShapes ssClassDep shapes |
	ssShapes := eGFInvocationModel classGroup copy.
	ssClassDep := eGFInvocationModel classDependencies copy.


	canvas := RSCanvas new.

	"canvas showEncompassingRectangles."
	shapes := ssShapes associations collect: [ :assoc | 
		          | group label s methods |
		          group := RSGroup new.

		          methods := assoc value collect: [ :met | 
			                     RSBox new
				                     model: met;
				                     popupText: #name;
				                     height: met cyclomaticComplexity + 10;
				                     width: met sourceText lines size + 10;
				                     yourself ].

		          RSGridLayout on: methods.
		          s := RSComposite new
			               color: (Color lightGray alpha: 0.4);
			               shapes: methods;
			               yourself.
		          s extent: s extent + 10.
		          "label of class group"
		          label := RSLabel new
			                   text: assoc key name;
			                   yourself.
		          group
			          add: label;
			          add: s.
		          RSVerticalLineLayout new alignCenter on: group.

		          RSComposite new
			          shapes: group;
			          model: assoc key;
			          draggable;
			          popup;
			          yourself ].

	canvas addAll: shapes.

	RSLineBuilder arrowedLine
		withBorderAttachPoint;
		canvas: canvas;
		beDirectional;
		connectToAll: [ :class | (ssClassDep at: class) asOrderedCollection ].

	canvas edges pushBack.
	RSHorizontalTreeLayout on: shapes.
	"canvas @ RSForceLayoutSteppingInteraction."
	"stepping := RSForceLayoutSteppingInteraction new.
	stepping layout
		length: 80;
		charge: -10000.
canvas @ stepping."

	"	RSForceBasedLayout new
		charge: -800;
		on: canvas nodes."


	canvas @ RSCanvasController.

	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFService >> buildInvocationGraphCanvas [

	| ssShapes shapes labeled start legend |
	ssShapes := eGFInvocationModel methods copy.

	canvas := RSCanvas new.
	shapes := OrderedCollection new.



	labeled := RSLabeled new.
	labeled highlightable.

	ssShapes associations do: [ :assoc | 
		| shape method color hasSQL hasStrangerIncomes srcCode |
		method := assoc key.
		srcCode := method sourceText.
		hasSQL := self hasSubString: srcCode containing: self sqlKeywords.


		"(((method name beginsWith: 'get') or: [ (method name beginsWith: 'set') ]) or: [ (method name beginsWith: 'is') ]) ifTrue: [
		hasSQL ifTrue: [ 
			shapes add:	(RSBox new size: 10 + (method cyclomaticComplexity); 
	model: method;
	addInteraction: labeled;
	draggable;
		popup;
	color:  color)
			 ]
		]ifFalse: [ 
		
	shapes add:	(RSEllipse new size: 10 + (method cyclomaticComplexity); 
	model: method;
	addInteraction: labeled;
	draggable;
		popup;
	color:  color).
		 ] "


		hasStrangerIncomes := self hasIncomingStranger: method.

		shape := RSBox new
			         model: method;
			         height: method cyclomaticComplexity + 10;
			         width: method sourceText lines size + 10;
			         "addInteraction: labeled;"border: (hasStrangerIncomes
					          ifTrue: [  ]
					          ifFalse: [ RSBorder new color: 'black' ]);
			         draggable;
			         popup;
			         color: (hasSQL
					          ifTrue: [ color := Color red translucent ]
					          ifFalse: [ Color blue translucent ]).
		shape @ RSHighlightable.
		shape when: RSMouseClick do: [ :evt | " 1 halt." ] for: self.
		shapes add: shape ].



	"add a starting indicator as node in the canvas, linked to the entry point"
	start := 'START'.
	ssShapes
		at: start
		ifAbsentPut: eGFInvocationModel entryPoint asOrderedCollection.

	shapes := shapes asOrderedCollection.

	shapes add: (RSLabel new
			 size: 10;
			 model: start;
			 draggable;
			 color: Color black).


	canvas addAll: shapes.

	RSEdgeBuilder arrowedLine
		borderColor: (Color gray alpha: 0.3);
		withBorderAttachPoint;
		canvas: canvas;
		connectToAll: [ :famixInvoc | ssShapes at: famixInvoc ].


	RSHorizontalTreeLayout new on: canvas nodes.

	"	RSForceBasedLayout new
		charge: -800;
		on: canvas nodes."

	"canvas @ RSForceLayoutSteppingInteraction."
	"stepping := RSForceLayoutSteppingInteraction new.
	stepping layout
		length: 80;
		charge: -300.
canvas @ stepping."

	canvas edges pushBack.
	canvas @ RSCanvasController.
	canvas zoomToFit.

	legend := self createLegend:
		          {'rectangle = methods invoked from the service endpoint' . 'rectangle size = height: method cyclomatic Complexity; width: method line of codes' . 'rectangle color = red: contain SPL; blue: based color' . 'rectangle border = only if the method is only invoked by other methods of this service'}.


	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFService >> createLegend: aStringArray [

	| legend |
	legend := RSLegend new container: canvas.
	aStringArray do: [ :aString | legend text: aString ].

	legend legendDo: [ :l | 
		l
			withBorder;
			padding: 25 ].
	legend build.
	^ legend
]

{ #category : #testing }
RSeGFService >> eGFInvocationModel: anEGFInvocationModel [
	eGFInvocationModel := anEGFInvocationModel.
]

{ #category : #testing }
RSeGFService >> hasIncomingStranger: method [

	| incomings |
	incomings := (method incomingInvocations 
		              collect: [ :invoc | invoc sender ]) select: [ :mth | 
		             eGFInvocationModel methods
			             at: mth
			             ifPresent: [ false ]
			             ifAbsent: [ true ] ].
	^ incomings size > 0
]

{ #category : #testing }
RSeGFService >> hasSubString: txt containing: keywords [

	| res |
	res := keywords select: [ :word | 
		       (txt capitalized findString: word capitalized) > 0 ].

 ^ res size > 0
]

{ #category : #'as yet unclassified' }
RSeGFService >> sqlKeywords [
	^ {  "'SQL' ." 'SELECT' . 'FROM'. 'WHERE'. 'INSERT'. 'UPDATE'. 'DELETE'. 'JOIN'. 'GROUP BY'. 'ORDER BY'. 'CREATE'. 'ALTER'. 'DROP' }.

]
