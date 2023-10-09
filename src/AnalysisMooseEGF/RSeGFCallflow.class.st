Class {
	#name : #RSeGFCallflow,
	#superclass : #Object,
	#instVars : [
		'canvas',
		'allMethods',
		'allClasses',
		'serviceTrace',
		'eGFCallflowModel',
		'otelTraces',
		'activeFilters'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'build canvas' }
RSeGFCallflow >> WIPNewClassDependenciesCanvas [

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

{ #category : #action }
RSeGFCallflow >> actionForExecutingSQL: shapes [
	"color in deep red the sql element that explicitly call for sql statement"
	(activeFilters at: #executingSQL)
		ifTrue: [ shapes do: [ :shp | shp color: Color red ] ]
		ifFalse: [ shapes do: [ :shape | self defaultRSBox: shape ] ].
	canvas signalUpdate
]

{ #category : #action }
RSeGFCallflow >> actionForGetterSetter: shapes [

	"finally, remove methods that are get/set"

	(activeFilters at: #getset)
		ifTrue: [ 
			shapes do: [ :shape | 
				shape
					color: Color transparent;
					border: (RSBorder new color: (Color black alpha: 0.1));
					removeInteractionIfPresent: RSDraggable ] ]
		ifFalse: [ shapes do: [ :shape | self defaultRSBox: shape ] ].
	canvas signalUpdate
]

{ #category : #action }
RSeGFCallflow >> actionForReferencingSQL: shapes [
"color the method that contains SQL references in their code"	
	(activeFilters at: #referencingSQL)
		ifTrue: [ shapes do: [ :shp | shp color: (Color red alpha: 0.4) ] ]
		ifFalse: [ shapes do: [ :shape | self defaultRSBox: shape ] ].
	canvas signalUpdate
]

{ #category : #adding }
RSeGFCallflow >> addHighlightEffect: aShape [

	| high method arrow |
	method := aShape model.
	arrow := RSShapeFactory arrowedLine
		         withBorderAttachPoint;
		         color: Color blue.
	high := RSHighlightable new.
	aShape @ high.
	
	high
		when: RSHighlightEvent do: [ :evt | 
			| invokedMethods invokingMethods arrows |
			"get the models, which are the invoked methods by our current method"
			invokedMethods := eGFCallflowModel invokedMethodsOf: method.
			invokingMethods := eGFCallflowModel invokingMethodsOf: method.

			"build and collect each arrow for outcoming invocation "
			arrows := (invokedMethods collect: [ :fromMet | 
					           | toMet |
					           "get the shape that as the model met"
					           toMet := allMethods shapeFromModel: fromMet.
					           "because we may filters the shapes, we have to check that the to-shapes really exists"
					           toMet isNotNil
						           ifTrue: [ "return an arrow from the shape fromMet (method) to the shape toMet. Because collect: need to return an object, we return nil if the shape does not exist"
							           arrow copy
								           from: evt shape;
								           to: toMet ]
						           ifFalse: [ nil ] ]) reject: #isNil.

			"build and collect each arrow for incoming invocation "
			arrows := arrows , ((invokingMethods collect: [ :toMet | 
				            | fromMeth |
				            fromMeth := allMethods shapeFromModel: toMet.
				            fromMeth isNotNil
					            ifTrue: [ "return an arrow from the shape fromMet (method) to the shape toMet. Because collect: need to return an object, we return nil if the shape does not exist"
						            arrow copy
							            from: fromMeth;
							            to: evt shape;
							            color: Color black ]
					            ifFalse: [ nil ] ]) reject: #isNil).

			canvas addAll: arrows.
			"we store the arrows reference into a canvas properties"
			canvas propertyAt: #arrows put: arrows ]
		for: self;
		when: RSUnHighlightEvent
		do: [ :evt | 
		(canvas propertyAt: #arrows ifAbsent: [ #(  ) ]) do: #remove ]
		for: self.

	^ aShape
]

{ #category : #accessing }
RSeGFCallflow >> allClasses [

	^ allClasses
]

{ #category : #accessing }
RSeGFCallflow >> allClasses: anObject [

	allClasses := anObject
]

{ #category : #filtering }
RSeGFCallflow >> applyFiltersOn: shapes [

	"apply filters on the shapes"
	"color the border of method are only invoked by method on this graph"
	(activeFilters at: #foreign) ifTrue: [ 
		(self
			 filterShapes: shapes
			 with: self filterShapesOnHavingForeignSenders) do: [ :shp | 
			shp border: nil ] ].


	
		self actionForReferencingSQL: (self filterShapes: shapes with: self filterShapesOnReferencingSQL).


	
	self actionForExecutingSQL: (self filterShapes: shapes with: self filterShapesOnExecutingSQL) .


	"	(self filterShapes: shapes with: self filterShapesOnUC) do: [ :shp | 
		shp color: Color green ]."

	"finally, remove methods that are get/set"
	(activeFilters at: #getset) ifTrue: [ 
		^ self filterShapes: shapes with: self filterShapesOnGettterSetter ].

	^ shapes
]

{ #category : #'build canvas' }
RSeGFCallflow >> buildClassDependenciesCanvas [

	| ssShapes ssClassDep shapes  |
	allMethods := RSGroup new.
	allClasses := RSGroup new.

	ssShapes := eGFCallflowModel classGroup copy.
	ssClassDep := eGFCallflowModel classDependencies copy.


	canvas := RSCanvas new.

	"canvas showEncompassingRectangles."
	shapes := ssShapes associations collect: [ :assoc | 
		          | group label composite methods class |
		          group := RSGroup new.

		          methods := assoc value collect: [ :met | 
			                     self buildMethodBox: met ].

		          self
			          toggled: #referencingSQL;
			          toggled: #executingSQL.
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
		          class := RSComposite new
			                   shapes: group;
			                   model: assoc key;
			                   draggable;
			                   popup;
			                   yourself.
		          allClasses add: class.
		          class ].

	canvas addAll: shapes.




	self drawTraceEdgeFrom: serviceTrace.


	(RSLineBuilder arrowedLine
		 withBorderAttachPoint;
		 color: (Color gray alpha: 0.2);
		 canvas: canvas;
		 beDirectional;
		 connectToAll: [ :class | 
			 (ssClassDep at: class) asOrderedCollection ]) pushBack.



	"LAYERS"


	"		layer := RSGroup new
		         addAll:
			         (self
				          filterShapes: allClasses
				          with: self filterShapesOnUCLayer);
		         add: (RSLabel new text: 'Layer UC');
		         yourself.
	RSHorizontalLineLayout new alignMiddle on: layer.
	canvas add: (RSComposite new
			 color: (Color green alpha: 0.4);
			 shapes: layer;
			 yourself)."

	(self filterShapes: allClasses with: self filterShapesOnUCLayer) do: [ 
		:shp | shp color: Color green ].

	(self filterShapes: allClasses with: self filterShapesOnServiceLayer) 
		do: [ :shp | shp color: Color yellow ].

	(self filterShapes: allClasses with: self filterShapesOnDAOLayer) 
		do: [ :shp | shp color: Color orange ].




	"RSHorizontalTreeLayout on: shapes."


	"RSClusterTreeLayout on: shapes."

	"	stepping := RSForceLayoutSteppingInteraction new.
	stepping layout
		length: 150;
		charge: -10000.
	canvas @ stepping.
"
	"RSForceBasedLayout new
		length: 300;
		charge: -10200;
		nodes: canvas nodes;
		edges: canvas edges;
		on: canvas nodes."

	canvas addShape: self buildOptionMenu.

	RSGridLayout on: canvas nodes.



	canvas @ RSCanvasController.

	^ canvas
]

{ #category : #'build canvas' }
RSeGFCallflow >> buildClassDependenciesCanvas2 [

	| ssShapes ssClassDep shapes uclayer serviceLayer dAOLayer transverseLayer layers othersLayer |
	allMethods := RSGroup new.
	allClasses := RSGroup new.

	ssShapes := eGFCallflowModel classGroup copy.
	ssClassDep := eGFCallflowModel classDependencies copy.

	"canvas propertyAt: #arrows put: arrows 
(canvas propertyAt: #arrows ifAbsent: [ #(  ) ]) do: #remove ]"

	canvas := RSCanvas new.

	"canvas showEncompassingRectangles."
	shapes := ssShapes associations collect: [ :assoc | 
		          | group label composite methods class |
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
		          composite extent: composite extent + 50.
		          "label of class group"
		          label := RSLabel new
			                   text: assoc key name;
			                   yourself.
		          "create the group for one class and its method"
		          group
			          add: label;
			          add: composite.
		          RSVerticalLineLayout new alignCenter on: group.
		          class := RSComposite new
			                   shapes: group;
			                   model: assoc key;
			                   draggable;
			                   popup;
			                   yourself.
		          allClasses add: class.
		          class ].

	canvas addAllShapes: shapes.

	"self drawTraceEdgeFrom: serviceTrace."



	"Construction des layers"

	layers := RSGroup new.

	uclayer := self
		           buildCompositeLayer:
		           (self
			            filterShapes: allClasses
			            with: self filterShapesOnUCLayer)
		           withName: 'usecase'
		           withColor: (Color lightGreen alpha: 0.5).
	layers add: uclayer.

	serviceLayer := self
		                buildCompositeLayer:
		                (self
			                 filterShapes: allClasses
			                 with: self filterShapesOnServiceLayer)
		                withName: 'service'
		                withColor: (Color lightYellow alpha: 0.5).
	layers add: serviceLayer.

	dAOLayer := self
		            buildCompositeLayer:
		            (self
			             filterShapes: allClasses
			             with: self filterShapesOnDAOLayer)
		            withName: 'DAO'
		            withColor: (Color lightOrange alpha: 0.5).
	layers add: dAOLayer.

	transverseLayer := self
		                   buildCompositeLayer: (self
				                    filterShapes: allClasses
				                    with: self filterShapesOnTransverseLayer)
		                   withName: 'transverse'
		                   withColor: (Color lightBlue alpha: 0.5).
	layers add: transverseLayer.


	othersLayer := self
		               buildCompositeLayer: canvas shapes
		               withName: 'other'
		               withColor: (Color lightMagenta alpha: 0.5).
	layers add: othersLayer.


	RSVerticalLineLayout new alignCenter on: layers.



	canvas addShape: (RSComposite new
			 shapes: layers;
			 yourself).













	"LAYERS"

	(self filterShapes: allClasses with: self filterShapesOnUCLayer) do: [ 
		:shp | shp color: Color green ].

	(self filterShapes: allClasses with: self filterShapesOnServiceLayer) 
		do: [ :shp | shp color: Color yellow ].

	(self filterShapes: allClasses with: self filterShapesOnDAOLayer) 
		do: [ :shp | shp color: Color orange ].




	"RSHorizontalTreeLayout on: shapes."


	"RSClusterTreeLayout on: shapes."

	"	stepping := RSForceLayoutSteppingInteraction new.
	stepping layout
		length: 150;
		charge: -10000.
	canvas @ stepping.
"
	"RSForceBasedLayout new
		length: 300;
		charge: -10200;
		nodes: canvas nodes;
		edges: canvas edges;
		on: canvas nodes."



	self heatmapColoringV3.

	canvas addShape: self buildOptionMenu.

	(RSLineBuilder arrowedLine
		 withBorderAttachPoint;
		 color: (Color gray alpha: 0.9);
		 shapes: allClasses;
		 beDirectional;
		 connectToAll: [ :class | 
			 (ssClassDep at: class) asOrderedCollection ]) pushBack.


	RSGridLayout on: canvas shapes.



	canvas @ RSCanvasController.

	^ canvas
]

{ #category : #'build shapes' }
RSeGFCallflow >> buildCompositeLayer: shapes withName: name withColor: color [

	| shapesCompo label boxGroup |
	boxGroup := RSGroup new.
	label := RSLabel new
		         text: name;
		         fontSize: 50;
					bold;
		         yourself.


	RSGridLayout on: shapes.
	shapesCompo := RSComposite new
		               shapes: shapes;
		               yourself.
	"shapes do: [ :shp | canvas removeShape: shp ]."
	shapesCompo extent: shapesCompo extent + 5.

	"create the group for one class and its method"
	boxGroup
		add: label;
		add: shapesCompo.
	RSVerticalLineLayout new alignCenter on: boxGroup.

	^ RSComposite new
		  shapes: boxGroup;
		  model: shapes;
		  color: color;
		  draggable;
		  popup;
		  yourself
]

{ #category : #'build canvas' }
RSeGFCallflow >> buildEdgeBundlingCanvas [

	| methods shapes |
	"shapes := OrderedCollection new."
	canvas := RSCanvas new.

	methods := eGFCallflowModel methods copy.

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

{ #category : #'build canvas' }
RSeGFCallflow >> buildInvocationGraphCanvas [

	| ssShapes shapes labeled start legend |
	allMethods := RSGroup new.

	ssShapes := eGFCallflowModel methods copy.

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
		ifAbsentPut: eGFCallflowModel entryPoint asOrderedCollection.

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

	legend := self buildLegend:
		          { 'rectangle = methods invoked from the service endpoint'.
		          'rectangle size = height: method cyclomatic Complexity; width: method line of codes'.
		          'rectangle color = red: contain SPL; blue: based color'.
		          'rectangle border = only if the method is only invoked by other methods of this service' }.


	^ canvas
]

{ #category : #'build shapes' }
RSeGFCallflow >> buildLegend: aStringArray [

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

{ #category : #'build shapes' }
RSeGFCallflow >> buildMethodBox: method [

	| srcCode shape |
	srcCode := method sourceText.


	shape := RSBox new
		         model: method;
		         height: method sourceText lines size + 10;
		         width: method cyclomaticComplexity + 10.
	shape when: RSMouseClick do: [ :evt | " 1 halt." ] for: self.
	self defaultRSBox: shape.
	self addHighlightEffect: shape.

	^ shape
]

{ #category : #'build shapes' }
RSeGFCallflow >> buildOptionMenu [

	| menu buttons |
	buttons := RSGroup new.

	buttons add: (RSLabel new
			 color: Color black;
			 model: 'ACTION MENU: ').

	buttons add: (RSLabel new
			 color: Color black;
			 model: '  • Getter Setter ';
			 when: RSMouseClick do: [ :evt | 
				 | shapes |
				 shapes := self
					           filterShapes: allMethods
					           with: self filterShapesOnGettterSetter.
				 self toggled: #getset.
				 self actionForGetterSetter: shapes ]
			 for: self;
			 yourself).

	buttons add: (RSLabel new
			 color: Color black;
			 model: '   • Executing SQL';
			 when: RSMouseClick do: [ :evt | 
				 | shapes |
				 shapes := self
					           filterShapes: allMethods
					           with: self filterShapesOnExecutingSQL.
				 self toggled: #executingSQL.
				 self actionForExecutingSQL: shapes ]
			 for: self;
			 yourself).

	buttons add: (RSLabel new
			 color: Color black;
			 model: '   • Referencing SQL ';
			 when: RSMouseClick do: [ :evt | 
				 | shapes |
				 shapes := self
					           filterShapes: allMethods
					           with: self filterShapesOnReferencingSQL.
				 self toggled: #referencingSQL.
				 self actionForReferencingSQL: shapes ]
			 for: self;
			 yourself).

	"force remove edges draw by highlight "
	buttons add: (RSLabel new
			 color: Color black;
			 model: '   • Reset ';
			 when: RSMouseClick do: [ :evt | 
				 allMethods do: [ :s | self defaultRSBox: s ].
				 (canvas propertyAt: #arrows ifAbsent: [ #(  ) ]) do: #remove.
				canvas signalUpdate ]
			 for: self;
			 yourself).

	RSVerticalLineLayout on: buttons.

	menu := buttons asShape
		        isFixed: true;
		        color: Color yellow;
		        border: (RSBorder new color: Color black translucent);
		        yourself.
	menu translateBy: menu extent / 2.

	^ menu
]

{ #category : #accessing }
RSeGFCallflow >> canvas [

	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> collectClassShapeFromTrace: aTraceAsOrderedCollection [

	| prunedTrace trace |
	
	
	trace := OrderedCollection new.

	prunedTrace := aTraceAsOrderedCollection collect: [ :t | 
		               t copyFrom: 1 to: (t lastIndexOf: $.) - 1 ].

	allClasses do: [ :shape | 
		| model |
		model := shape model.

		prunedTrace do: [ :t | 
			((model mooseNameWithDots asLowercase findString: t asLowercase) > 0) ifTrue: [
				trace add: t -> shape ] ] ]
]

{ #category : #'build canvas' }
RSeGFCallflow >> debugCanvasBuilding [

	| ssShapes shapes labeled start legend |
	ssShapes := eGFCallflowModel methods copy.

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
		ifAbsentPut: eGFCallflowModel entryPoint asOrderedCollection.

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

	legend := self buildLegend:
		          { 'rectangle = methods invoked from the service endpoint'.
		          'rectangle size = height: method cyclomatic Complexity; width: method line of codes'.
		          'rectangle color = red: contain SPL; blue: based color'.
		          'rectangle border = only if the method is only invoked by other methods of this service' }.


	^ canvas
]

{ #category : #'build shapes' }
RSeGFCallflow >> defaultRSBox: rsBox [

	^ rsBox
		  draggable;
		  popup;
		  border: (RSBorder new color: 'black');
		  color: Color black translucent;
		  "height: rsBox model sourceText lines size + 10;
		  width: rsBox model cyclomaticComplexity + 10;"
			  yourself
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> drawTraceEdgeFrom: aTraceAsOrderedCollection [

	| trace traceModel |
	trace := aTraceAsOrderedCollection collect: [ :moosename | 
		         self findShapeIn: allMethods FromMoosename: moosename ].

	traceModel := trace collect: [ :s | s model ].


	(RSLineBuilder arrowedLine
		borderColor: Color red;
		withBorderAttachPoint;
		beDirectional;
		width: 5;
		shapes: trace;
		canvas: canvas;
		connectToAll: [ :m | 
			| index res |
			res := Set new.
			index := traceModel indexOf: m.
			index > 1
				ifTrue: [ res add: (traceModel at: index - 1) ]
				ifFalse: [ res := Set new ].

			res ]) pushFront.
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> drawV2TraceEdgeFrom: aTraceAsOrderedCollection [

	| trace traceModel innerTrace |
	trace := aTraceAsOrderedCollection collect: [ :moosename | 
		         self findShapeIn: allMethods FromMoosename: moosename ].

	traceModel := trace collect: [ :s | s model ].

	"innerTrace := trace select: [ :m | 
		              (m = trace first or: [ m = trace last ]) not ]."
	1 halt.
	innerTrace := trace select: [ :m | (m = (trace at: (trace size / 2 )))].

	MyRSMultiBezierEdgeBuilder multiBezier
		borderColor: Color red;
		shapes: trace;
		width: 20;
		canvas: canvas;
		tension: 1.0;
		following: [ :m | innerTrace ];
		useAssociation: traceModel last -> traceModel first
]

{ #category : #testing }
RSeGFCallflow >> eGFCallflowFromModel: anEGFCallflowModel [

	eGFCallflowModel := anEGFCallflowModel
]

{ #category : #setter }
RSeGFCallflow >> executionTrace: aCollection [ 
	self shouldBeImplemented.
]

{ #category : #filtering }
RSeGFCallflow >> filterShapes: shapes with: aBlock [

	"return a collection of RS object filter by the statement given in aBlock."

	"block must ends with true or false "

	^ shapes select: [ :elmt | aBlock value: elmt ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnDAOLayer [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | class |
	  class := elmt model.
	  ((class superclassHierarchy select: [ :sc | sc name = #DaoAbstract ])
		  isNotEmpty) or: [ 
		  class mooseName includesSubstring: 'DAO' caseSensitive: false ] 
		
		
		]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnExecutingSQL [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.

	  self
		  hasSubString: method sourceText
		  containing: { 'sqlstatement'. 'executequery'. 'executeupdate' } ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnGettterSetter [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	  ((method name beginsWith: 'get') or: [ 
		   (method name beginsWith: 'set') or: [ 
			   method name beginsWith: 'is' ] ]) ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnHavingForeignSenders [

	"return a filtering block to excludes shapes associated with a methods model that receive invocation from method that are not in this methods group"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	  self hasForeignSenders: method ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnReferencingSQL [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | method |
	  method := elmt model.
	 self hasSubString: method sourceText containing: self sqlKeywords.
	]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnServiceLayer [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | class |
	  class := elmt model.
	 ((class superclassHierarchy select: [ :sc | 
		   sc name = #ServiceAbstract ]) isNotEmpty) or: [ (class mooseName includesSubstring: 'service' caseSensitive:  false) ]
	 ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnTransverseLayer [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | class |
	  class := elmt model.
		  class mooseName includesSubstring: 'transverse' caseSensitive: false  ]
]

{ #category : #filtering }
RSeGFCallflow >> filterShapesOnUCLayer [

	"return a filtering block to excludes shapes associated with a methods model that begins with get/set"

	^ [ :elmt | 
	  | class |
	  class := elmt model.
	  ((class superclassHierarchy select: [ :sc | sc name = #RemoteServer ])
		  isNotEmpty) or: [ 
		  class mooseName includesSubstring: 'usecase' caseSensitive: false ] ]
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> findShapeIn: aCollection FromMoosename: aMooseName [

	^ (aCollection select: [ :shape | 
		|regex|
		
			
		aMooseName endsWith: shape model mooseNameWithDotsNoParenthesisNoPackageName
		 ]) anyOne
]

{ #category : #testing }
RSeGFCallflow >> hasForeignSenders: aMethod [

	" check if aMethod receive invocation from method that are not in the current invocation model"

	| incomings |
	incomings := (aMethod incomingInvocations collect: [ :invoc | 
		              invoc sender ]) select: [ :mth | 
		             eGFCallflowModel methods
			             at: mth
			             ifPresent: [ false ]
			             ifAbsent: [ true ] ].
	^ incomings isNotEmpty
]

{ #category : #testing }
RSeGFCallflow >> hasSubString: txt containing: keywords [

	| res |
	res := keywords select: [ :word | 
		       (txt asLowercase  findString: word asLowercase) > 0 ].

	^ res isNotEmpty
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> heatmapColoring [

	| colorPalette dic |
	self
		deprecated: 'Use #heatmapColoringV2 instead'
		on: '9 October 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	dic := Dictionary new.
	colorPalette := NSScale linear
		                range: { 
				                Color white.
				                Color red };
		                domain: { 0. 1000 };
		                yourself.

	otelTraces traces valuesDo: [ :t | 
		t famixMethodCandidates do: [ :mth | 
			| shape lvl |
			shape := allMethods shapesFromModel: mth.
			lvl := dic at: mth ifAbsentPut: [ 0 ].
			shape color: (colorPalette scale: (dic at: mth put: lvl + 1)) ] ]
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> heatmapColoringV2 [

	| colorPalette dic |
	dic := Dictionary new.
	colorPalette := NSScale linear
		                range: { 
				                Color white.
				                Color red };
		                domain: { 0. 50 };
		                yourself.

	otelTraces tracesGrpBySignature valuesDo: [ :traces | 
		| heat shp |
		heat := traces size.
		shp := allMethods shapesFromModel:
			       traces anyOne famixMethodCandidates anyOne.
		shp color: (colorPalette scale: heat) ]
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> heatmapColoringV3 [

	| colorPalette dic shapes|
	dic := Dictionary new.
	colorPalette := NSScale linear
		                range: { 
				                Color white.
				                Color red };
		                domain: { 0. 50 };
		                yourself.

"RSNormalizer color
		  scale: colorPalette;
		  shapes: self shapes;
		  normalize: [ :el | 
			  self maxDomainValue
				  ifNotNil: [ :max | (self nodeValueBlock value: el) min: max ]
				  ifNil: [ self nodeValueBlock value: el ] ]"
		
	shapes := (otelTraces tracesGrpBySignature associations collect: [ :asso | 
			|traces sh|
			traces := asso value.
			(allMethods shapesFromModel:
			       traces anyOne famixMethodCandidates anyOne) anyOne -> traces size.]) asDictionary .
		
	 
	RSNormalizer color
		  scale: colorPalette;
		  shapes: shapes keys;
		  normalize: [ :el | 
			  nil
				  ifNotNil: [ :max | (shapes at: el) min: max ]
				  ifNil: [ (shapes at: (allMethods shapesFromModel: el) anyOne) ] ].
	
	
"	otelTraces tracesGrpBySignature valuesDo: [ :traces | 
		| heat shp |
		heat := traces size.
		shp := allMethods shapesFromModel:
			       traces anyOne famixMethodCandidates anyOne.
		shp color: (colorPalette scale: heat) ]"
]

{ #category : #filtering }
RSeGFCallflow >> highlightClassesOfTrace: aTraceAsOrderedCollect [


	self collectClassShapeFromTrace: aTraceAsOrderedCollect.

	allClasses do: [ :shape | 
		| model isIn trace |
		model := shape model.

		"self haltIf: [ model name = 'SqlPreparedStatement' ]."

		trace := aTraceAsOrderedCollect collect: [ :t | 
			         t copyFrom: 1 to: (t lastIndexOf: $.) - 1 ].

		isIn := self hasSubString: model mooseNameWithDots containing: trace.
		isIn ifTrue: [ shape color: Color purple translucent ] ]
]

{ #category : #initialization }
RSeGFCallflow >> initialize [

	serviceTrace := OrderedCollection new.
	activeFilters := Dictionary
		                 newFrom: { 
				                 (#foreign -> false).
				                 (#referencingSQL -> false).
				                 (#executingSQL -> false).
				                 (#getset -> false) }.
]

{ #category : #testing }
RSeGFCallflow >> model: anEGFCallflowModel [

	eGFCallflowModel := anEGFCallflowModel
]

{ #category : #setter }
RSeGFCallflow >> otelTraces: aCollection [

	otelTraces := aCollection
]

{ #category : #setter }
RSeGFCallflow >> serviceTrace: aCollection [

	serviceTrace := aCollection
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> sqlKeywords [

	^ { 'SELECT'. 'FROM'. 'WHERE'. 'INSERT'. 'UPDATE'.
	  'DELETE'. 'JOIN'. 'GROUP BY'. 'ORDER BY'. 'CREATE'.
	  'ALTER'. 'DROP '. 'SQL'. 'IS NULL' }
]

{ #category : #'as yet unclassified' }
RSeGFCallflow >> toggled: key [ 
	activeFilters at: key put: (activeFilters at: key) not
]
