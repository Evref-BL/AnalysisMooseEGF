Class {
	#name : #BaselineOfAnaysisMooseEgf,
	#superclass : #BaselineOf,
	#category : #BaselineOfAnalysisMooseEGF
}

{ #category : #baselines }
BaselineOfAnaysisMooseEgf >> baseline: spec [


	<baseline>
	spec for: #common do: [ 
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : #'as yet unclassified' }
BaselineOfAnaysisMooseEgf >> defineDependencies: spec [

	"donne les ref vers le projet qui se trouve sur un depot distance (je crois)"

	spec
		baseline: 'Moose'
		with: [ 
		spec repository: 'github://moosetechnology/Moose:development/src' ].
	
	spec
				baseline: 'Roassal3'
				with: [ spec repository: 'github://ObjectProfile/Roassal3/src' ]
]

{ #category : #defaults }
BaselineOfAnaysisMooseEgf >> defineGroups: spec [
"aucune idée"
]

{ #category : #defaults }
BaselineOfAnaysisMooseEgf >> definePackages: spec [

	spec
		package: 'AnalysisMooseEGF';
		package: 'Moose';
		package: 'Roassal3'
]
