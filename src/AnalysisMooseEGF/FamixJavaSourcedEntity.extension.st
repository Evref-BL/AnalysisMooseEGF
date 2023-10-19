Extension { #name : #FamixJavaSourcedEntity }

{ #category : #'*AnalysisMooseEGF' }
FamixJavaSourcedEntity >> miMySourceInspectorExtension [

	<inspectorPresentationOrder: 3 title: 'Source code File'>

	^ MiSourceExtension on: self sourceAnchor
]
