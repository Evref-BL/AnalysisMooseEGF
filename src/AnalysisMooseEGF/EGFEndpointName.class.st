Class {
	#name : #EGFEndpointName,
	#superclass : #Object,
	#instVars : [
		'firstWords'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #accessing }
EGFEndpointName >> firstWords [

	^ firstWords
]

{ #category : #accessing }
EGFEndpointName >> firstWords: anObject [

	firstWords := anObject
]

{ #category : #initialization }
EGFEndpointName >> initialize [ 
	firstWords := Dictionary new. 
]

{ #category : #inspector }
EGFEndpointName >> inspectionEndpointWording [

	<inspectorPresentationOrder: 1 title: 'Word occurrences'>
	| canvas shapes |
	canvas := RSCanvas new.

	shapes := firstWords associations collect: [ :assoc | 
		          | word occu lbl box |
		          word := assoc key.
		          occu := assoc value.

		          lbl := RSLabel new
			                 text: word asString;
			                 yourself.
		          box := RSEllipse new
			                 radius: occu;
			                 extent: lbl extent + 10.

		          RSComposite new
			          draggable;
			          model: assoc;
			          shapes: (RSGroup with: box with: lbl) ].


	"RSNormalizer size
		shapes: shapes;
		to: 50;
		normalize: [ :assoc | assoc value ]."

	canvas addAll: shapes.

	RSGridLayout on: canvas nodes.
	canvas @ RSCanvasController.
	^ canvas asPresenter
]
