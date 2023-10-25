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

{ #category : #accessing }
BaselineOfAnalysisMooseEGF >> customProjectAttributes [ 

	^ RPackageOrganizer default packages
		  detect: [ :package | package name = 'BaselineOfFamix' ]
		  ifFound: [ #(  ) ]
		  ifNone: [ #( #NeedsMoose ) ]
]

{ #category : #'as yet unclassified' }
BaselineOfAnalysisMooseEGF >> defineDependencies: spec [

	"donne les ref vers le projet qui se trouve sur un depot distance (je crois)"

spec baseline: 'FamixOpenTelemetry' with: [ 
			spec
			
				repository: 'github://moosetechnology/Famix-OpenTelemetry:main/src' ].

spec for: #NeedsMoose do: [ 
		spec baseline: 'Famix' with: [ 
			spec
				loads: #( 'Core' 'Basic' );
				repository: 'github://moosetechnology/Famix:development/src' ].]
		
		


]

{ #category : #defaults }
BaselineOfAnalysisMooseEGF >> defineGroups: spec [
"aucune idée"
]

{ #category : #defaults }
BaselineOfAnalysisMooseEGF >> definePackages: spec [

	spec
		package: 'AnalysisMooseEGF' with: [ spec requires: 'FamixOpenTelemetry' ];
		package: 'AnalysisMooseEGF-service-extractor'.
]
