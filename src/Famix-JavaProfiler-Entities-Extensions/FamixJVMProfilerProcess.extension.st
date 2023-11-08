Extension { #name : #FamixJVMProfilerProcess }

{ #category : #'*Famix-JavaProfiler-Entities-Extensions' }
FamixJVMProfilerProcess >> printOn: aStream [

	aStream << 'an JVMProcess '.
	aStream << ': '.
	(self subProcesses size) printOn: aStream.
]
