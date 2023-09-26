Extension { #name : #FamixJavaSourcedEntity }

{ #category : #'*AnalysisMooseEGF' }
FamixJavaSourcedEntity >> miMySourceInspectorExtension [

	<inspectorPresentationOrder: 3 title: 'Source code File'>
	1 halt.
	^ MiSourceExtension on: self sourceAnchor
]
