Class {
	#name : #BaselineOfAnalysisMooseEGF,
	#superclass : #BaselineOf,
	#category : #BaselineOfAnalysisMooseEGF
}

{ #category : #baselines }
BaselineOfAnalysisMooseEGF >> baseline: spec [


	<baseline>
	spec for: #common do: [ 
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : #'as yet unclassified' }
BaselineOfAnalysisMooseEGF >> defineDependencies: spec [

	"donne les ref vers le projet qui se trouve sur un depot distance (je crois)"

"	spec
		baseline: 'Moose'
		with: [ 
		spec repository: 'github://moosetechnology/Moose:development/src' ].
	
	spec
				baseline: 'Roassal3'
				with: [ spec repository: 'github://ObjectProfile/Roassal3/src' ]"
]

{ #category : #defaults }
BaselineOfAnalysisMooseEGF >> defineGroups: spec [
"aucune idée"
]

{ #category : #defaults }
BaselineOfAnalysisMooseEGF >> definePackages: spec [

	spec
		package: 'AnalysisMooseEGF';
		package: 'AnalysisMooseEGF-service-extractor'
]
