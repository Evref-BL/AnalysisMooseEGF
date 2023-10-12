Class {
	#name : #RSeGFTraces,
	#superclass : #Object,
	#instVars : [
		'canvas',
		'model'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
RSeGFTraces >> buildCanvas [

	| shapes colorPalette edges methodToTraces lines colorPaletteLines |
	self computeTraceHistoric.
	edges := self computeEdgeTraces.

	methodToTraces := self computeFamixMethodToTraces.
	
	colorPalette := NSScale sqrt
		                range: { 
				                Color white.
				                Color red };
		                domain: { 0. 50 };
		                yourself.


	colorPaletteLines := NSScale linear
		                     range: { #paleRed. #red };
		                     domain: { 0. 100 };
		                     yourself.

	canvas := RSCanvas new.

	shapes := model tracesGrpBySignature associations collect: [ :assoc | 
		          | rsMth signature trace |
		          signature := assoc key.
		          trace := assoc value anyOne.
		          rsMth := RSCircle new
			                   model: trace famixMethodCandidates first;
			                   radius: assoc value size;
			                   draggable;
			                   noPaint;
			                   border: (RSBorder new
					                    width: 2;
					                    color: Color black);
			                   yourself.

		          rsMth @ (RSPopup text: [ :shpModel | 
			           '[' , assoc value size asString , '] :: '
			           , trace methodSignature ]).
		          rsMth ].

	RSNormalizer color
		scale: colorPalette;
		shapes: shapes;
		normalize: [ :shpModel | (methodToTraces at: shpModel) size ].

	canvas addAll: shapes.
	RSNormalizer size
		from: 20;
		to: 500;
		shapes: shapes;
		normalize: [ :shpModel | (methodToTraces at: shpModel) size ].
	RSHorizontalLineLayout on: shapes.


	lines := (edges associations collect: [ :entry | 
		          RSLineBuilder arrowedLine
			          borderColor: Color black;
			          withBorderAttachPoint;
			          beDirectional;
			          width: 3.5;
			          shapes: shapes;
			          canvas: canvas;
			          useAssociation: entry key ]) reject: #isNil.

	lines do: [ :l | 
		l @ (RSPopup text: [ :shpModel | (edges at: shpModel) asString ]).
		l ].

	RSNormalizer color
		scale: colorPaletteLines;
		shapes: lines;
		normalize: [ :shpModel | edges at: shpModel ].




	RSHorizontalTreeLayout on: canvas nodes.


	canvas @ RSCanvasController.
	^ canvas
]

{ #category : #'as yet unclassified' }
RSeGFTraces >> computeEdgeTraces [

	| checker traces sequences max |
	checker := OrderedCollection new.
	traces := model traces values.
	max := traces size.
	1 to: max do: [ :i | 
		| trace |
		trace := traces at: i.
		trace order asInteger = i ifFalse: [ checker add: trace ] ].

	self
		assert: [ checker isEmpty ]
		description:
		'checker should be empty, otherwise trace are not in a continius order'.

	sequences := OrderedDictionary new.

	1 to: (max-1)  do: [ :x | 
		| y link |
		y := x + 1.

		((traces at: x) famixMethodCandidates isNotEmpty and: [ 
			 (traces at: y) famixMethodCandidates isNotEmpty ]) ifTrue: [ 
			link := (traces at: x) famixMethodCandidates first
			        -> (traces at: y) famixMethodCandidates first.
			sequences
				at: link
				ifPresent: [ sequences at: link put: (sequences at: link) + 1 ]
				ifAbsent: [ sequences at: link put: 1 ] ] ].

	^ sequences
]

{ #category : #'as yet unclassified' }
RSeGFTraces >> computeFamixMethodToTraces [

	^ (model tracesGrpBySignature associations collect: [ :assoc | 
		  assoc value anyOne famixMethodCandidates anyOne -> assoc value ]) asDictionary 
]

{ #category : #'as yet unclassified' }
RSeGFTraces >> computeTraceHistoric [

	| historic i|
	historic := OrderedDictionary new.
	i := 0.
	model traces values do: [ :t | 
		| fmxMth |
		fmxMth := t famixMethodCandidates ifNotEmpty: #anyOne ifEmpty: nil .
		fmxMth ifNotNil: [ 
			i := i + 1.
			historic
				at: fmxMth
				ifPresent: [ 
					|orders|
					
					orders := historic at: fmxMth.
					orders add: t order.
					historic at: fmxMth put: orders ]
				ifAbsent: [ 
					historic at: fmxMth put: (OrderedCollection new
							 add: t order;
							 yourself) ] ] ].
	1 halt.
	^ historic
]

{ #category : #accessing }
RSeGFTraces >> model: anEGFTraceModel [ 

	model := anEGFTraceModel
]
