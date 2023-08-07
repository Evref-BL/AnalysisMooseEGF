Class {
	#name : #RSeGFService,
	#superclass : #Object,
	#instVars : [
		'eGFInvocationModel',
		'canvas',
		'allMethods'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
RSeGFService >> WIPNewClassDependenciesCanvas [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	| packagesRegExp packages popup label padding high arrow allClasses |
	allMethods := nil.

	packagesRegExp := { 'Roassal3-Shapes' }.

	packages := packagesRegExp flatCollect: [ :regExp | 
		            RPackageOrganizer default packages select: [ :p | 
			            regExp match: p packageName ] ].

	canvas := RSCanvas new.
	popup := RSPopup new.
	label := RSLabeled new highlightable.
	label shapeBuilder labelShape color: Color black.
	padding := 10 asMargin.
	high := RSHighlightable new.
	arrow := RSShapeFactory arrowedLine
		         withBorderAttachPoint;
		         color: Color blue.
	packages := packages collect: [ :p | 
		            | classes pkg |
		            classes := p definedClasses
			                       collect: [ :cls | 
				                       | methods |
				                       methods := cls methods collect: [ :met | 
					                                  RSBox new
						                                  extent: 5 @ met linesOfCode;
						                                  @ popup;
						                                  @ high;
						                                  model: met;
						                                  yourself ].
				                       RSGridLayout on: methods.
				                       RSComposite new
					                       model: cls;
					                       @ label;
					                       @ popup;
					                       paint: Color white;
					                       children: methods;
					                       padding: padding;
					                       yourself ]
			                       as: RSGroup.
		            pkg := (classes asShapeFor: p)
			                   paint: Color veryVeryLightGray translucent;
			                   @ popup;
			                   yourself.
		            RSLineBuilder orthoVertical
			            withVerticalAttachPoint;
			            canvas: pkg;
			            shapes: pkg nodes;
			            connectFrom: #superclass.
		            RSTreeLayout on: pkg nodes edges: pkg edges.
		            pkg
			            position: 0 @ 0;
			            adjustToChildren;
			            padding: padding.
		            pkg ].
	canvas addAll: packages.
	RSGridLayout on: canvas shapes.
	allClasses := canvas shapes flatCollect: #nodes.
	allMethods := allClasses flatCollect: #nodes.

	high
		when: RSHighlightEvent do: [ :evt | 
			| methods |
			1 halt.
			methods := allClasses flatCollect: [ :class | 
					           (class model thoroughWhichMethodsReferTo:
							            evt shape model selector) collect: [ :method | 
							           method ] ].
			methods := methods collect: [ :met | 
					           arrow copy
						           from: evt shape;
						           to: (allMethods shapeFromModel: met) ].
			canvas addAll: methods.
			canvas propertyAt: #methods put: methods ]
		for: self;
		when: RSUnHighlightEvent do: [ :evt | 
			(canvas propertyAt: #methods ifAbsent: [ #(  ) ]) do: #remove ]
		for: self.

	canvas @ RSCanvasController.
	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFService >> applyFiltersOn: shapes [

	"apply 3 commons filter on the shapes""color the border of method are only invoked by method on this graph"

	(self
		 filterShapes: shapes
		 with: self filterShapesOnHavingForeignSenders) do: [ :shp | 
		shp border: nil ].

	"color the method that contains SQL references in their code"
	(self filterShapes: shapes with: self filterShapesOnReferencingSQL) 
		do: [ :shp | shp color: (Color red alpha: 0.4) ].

	"color in deep red the sql element that explicitly call for sql statement"
	(self filterShapes: shapes with: self filterShapesOnExecutingSQL) 
		do: [ :shp | shp color: Color red ].



	"finally, remove methods that are get/set"
	^ self filterShapes: shapes with: self filterShapesOnGettterSetter
]

{ #category : #'as yet unclassified' }
RSeGFService >> buildClassDependenciesCanvas [

	| ssShapes ssClassDep shapes |
	allMethods := RSGroup new.

	ssShapes := eGFInvocationModel classGroup copy.
	ssClassDep := eGFInvocationModel classDependencies copy.


	canvas := RSCanvas new.

	"canvas showEncompassingRectangles."
	shapes := ssShapes associations collect: [ :assoc | 
		          | group label composite methods |
		          group := RSGroup new.

		          methods := assoc value collect: [ :met | 
			                     self buildMethodBox: met ].

		          methods := self applyFiltersOn: methods.

		         	allMethods addAll: methods. 

		          RSGridLayout on: methods.
		          "composite that regroup methods of an Class"
		          composite := RSComposite new
			                       color: (Color lightGray alpha: 0.4);
			                       shapes: methods;
			                       yourself.
		          composite extent: composite extent + 100.
		          "label of class group"
		          label := RSLabel new
			                   text: assoc key name;
			                   yourself.
		          "create the group for one class and its method"
		          group
			          add: label;
			          add: composite.
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
RSeGFService >> buildEdgeBundlingCanvas [

	| methods shapes |
	"shapes := OrderedCollection new."
	canvas := RSCanvas new.

	methods := eGFInvocationModel methods copy.

	shapes := methods associations asSet
		          collect: [ :assoc | 
			          RSEllipse new
				          draggable;
				          popup;
				          model: assoc key;
				          yourself ]
		          as: RSGroup.

	canvas addAll: shapes.

	RSEdgeBuilder arrowedLine
		borderColor: (Color gray alpha: 0.3);
		withBorderAttachPoint;
		canvas: canvas;
		connectToAll: [ :famixInvoc | methods at: famixInvoc ].



	RSNormalizer size
		shapes: shapes;
		to: 20;
		normalize: #cyclomaticComplexity.


	1 halt.

	"RSNormalizer color
		shapes: methods;
		normalize: #numberOfMethods."


	RSClusterTreeLayout on: shapes.

	"RSMultiBezierEdgeBuilder multiBezier
		borderColor: (Color blue alpha: 0.3);
		canvas: canvas;
		shapes: shapes;
		withBorderAttachPoint;
		following: #superclass;
		connectToAll: [ :famixInvoc | shapes at: famixInvoc ]."
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFService >> buildInvocationGraphCanvas [

	| ssShapes shapes labeled start legend |
	allMethods := RSGroup new.

	ssShapes := eGFInvocationModel methods copy.

	canvas := RSCanvas new.
	shapes := OrderedCollection new.



	labeled := RSLabeled new.
	labeled highlightable.

	shapes := ssShapes associations collect: [ :assoc | 
		          | method |
		          method := assoc key.
		          self buildMethodBox: method ].


	shapes := self applyFiltersOn: shapes.
	allMethods addAll: shapes.


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
		          { 'rectangle = methods invoked from the service endpoint'.
		          'rectangle size = height: method cyclomatic Complexity; width: method line of codes'.
		          'rectangle color = red: contain SPL; blue: based color'.
		          'rectangle border = only if the method is only invoked by other methods of this service' }.


	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFService >> buildMethodBox: method [

	| srcCode shape high arrow |
	arrow := RSShapeFactory arrowedLine
		         withBorderAttachPoint;
		         color: Color blue.
	srcCode := method sourceText.

	high := RSHighlightable new.

	shape := RSBox new
		         model: method;
		         height: method sourceText lines size + 10;
		         width: method cyclomaticComplexity + 10;
		         draggable;
		         popup;
		         border: (RSBorder new color: 'black');
		         color: Color blue translucent.
	shape when: RSMouseClick do: [ :evt | " 1 halt." ] for: self.
	shape @ high.


	high
		when: RSHighlightEvent do: [ :evt | 
			| methods arrows |
			methods := eGFInvocationModel methods at: method.

			arrows := (methods collect: [ :met | 
					           | toMet |
					           toMet := allMethods shapeFromModel: met.
					           toMet isNotNil
						           ifTrue: [ 
							           arrow copy
								           from: evt shape;
								           to: toMet ]
						           ifFalse: [ nil ] ]) reject: #isNil.
			canvas addAll: arrows.
			canvas propertyAt: #arrows put: arrows ]
		for: self;
		when: RSUnHighlightEvent
		do: [ :evt | 
		(canvas propertyAt: #arrows ifAbsent: [ #(  ) ]) do: #remove ]
		for: self.


	^ shape
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

{ #category : #'as yet unclassified' }
RSeGFService >> debugCanvasBuilding [

	| ssShapes shapes labeled start legend |
	ssShapes := eGFInvocationModel methods copy.

	canvas := RSCanvas new.
	shapes := OrderedCollection new.



	labeled := RSLabeled new.
	labeled highlightable.

	ssShapes associations do: [ :assoc | 
		| shape method srcCode |
		method := assoc key.
		srcCode := method sourceText.

		(((method name beginsWith: 'get') or: [ 
			  method name beginsWith: 'set' ]) or: [ 
			 method name beginsWith: 'is' ])
			ifTrue: [ 
				(self hasSubString: srcCode containing: self sqlKeywords) ifTrue: [ 
					shape := self buildMethodBox: method.
					shape @ RSHighlightable.
					shape when: RSMouseClick do: [ :evt | " 1 halt." ] for: self.
					shapes add: shape ] ]
			ifFalse: [ 
				shape := self buildMethodBox: method.
				shape @ RSHighlightable.
				shape when: RSMouseClick do: [ :evt | " 1 halt." ] for: self.
				shapes add: shape ] ].

	shapes := self filterShapes: shapes with: [ :shape | 
		          | srcCode |
		          srcCode := shape model sourceText.
		          srcCode beginsWith: 'public' ].


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
		          { 'rectangle = methods invoked from the service endpoint'.
		          'rectangle size = height: method cyclomatic Complexity; width: method line of codes'.
		          'rectangle color = red: contain SPL; blue: based color'.
		          'rectangle border = only if the method is only invoked by other methods of this service' }.


	^ canvas
]

{ #category : #testing }
RSeGFService >> eGFInvocationModel: anEGFInvocationModel [
	eGFInvocationModel := anEGFInvocationModel.
]

{ #category : #filtering }
RSeGFService >> filterShapes: shapes with: aBlock [

	"return a collection of RS object filter by the statement given in aBlock."

	"block must ends with true or false "

	^ shapes select: [ :elmt | aBlock value: elmt ]
]

{ #category : #filtering }
RSeGFService >> filterShapesOnExecutingSQL [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.

	  self
		  hasSubString: method sourceText
		  containing: { 'sqlstatement'. 'executequery'. 'executeupdate' } ]
]

{ #category : #filtering }
RSeGFService >> filterShapesOnGettterSetter [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	  ((method name beginsWith: 'get') or: [ 
		  (method name beginsWith: 'set') or: [ 
			  method name beginsWith: 'is' ] ]) not ]
]

{ #category : #filtering }
RSeGFService >> filterShapesOnHavingForeignSenders [

	"return a filtering block to excludes shapes associated with a methods model that receive invocation from method that are not in this methods group"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	  self hasForeignSenders: method ]
]

{ #category : #filtering }
RSeGFService >> filterShapesOnReferencingSQL [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	 self hasSubString: method sourceText containing: self sqlKeywords.
	]
]

{ #category : #testing }
RSeGFService >> hasForeignSenders: aMethod [

	" check if aMethod receive invocation from method that are not in the current invocation model"

	| incomings |
	incomings := (aMethod incomingInvocations collect: [ :invoc | 
		              invoc sender ]) select: [ :mth | 
		             eGFInvocationModel methods
			             at: mth
			             ifPresent: [ false ]
			             ifAbsent: [ true ] ].
	^ incomings isNotEmpty
]

{ #category : #testing }
RSeGFService >> hasSubString: txt containing: keywords [

	| res |
	res := keywords select: [ :word | 
		       (txt asLowercase  findString: word asLowercase) > 0 ].

	^ res isNotEmpty
]

{ #category : #'as yet unclassified' }
RSeGFService >> sqlKeywords [

	^ { 'SELECT'. 'FROM'. 'WHERE'. 'INSERT'. 'UPDATE'.
	  'DELETE'. 'JOIN'. 'GROUP BY'. 'ORDER BY'. 'CREATE'.
	  'ALTER'. 'DROP '. 'SQL'. 'IS NULL' }
]
