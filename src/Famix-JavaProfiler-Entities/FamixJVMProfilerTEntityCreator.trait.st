Trait {
	#name : #FamixJVMProfilerTEntityCreator,
	#category : #'Famix-JavaProfiler-Entities-Model'
}

{ #category : #'instance creation' }
FamixJVMProfilerTEntityCreator >> newProcess [

	<generated>
	^ self add: FamixJVMProfilerProcess new
]

{ #category : #'instance creation' }
FamixJVMProfilerTEntityCreator >> newProfile [

	<generated>
	^ self add: FamixJVMProfilerProfile new
]
