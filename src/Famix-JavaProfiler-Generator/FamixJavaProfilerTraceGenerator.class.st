Class {
	#name : #FamixJavaProfilerTraceGenerator,
	#superclass : #FamixMetamodelGenerator,
	#instVars : [
		'profile',
		'javaProcess'
	],
	#category : #'Famix-JavaProfiler-Generator'
}

{ #category : #accessing }
FamixJavaProfilerTraceGenerator class >> packageName [

	<ignoreForCoverage>
	^ #'Famix-JavaProfiler-Entities'
]

{ #category : #accessing }
FamixJavaProfilerTraceGenerator class >> prefix [

	<ignoreForCoverage>
	^ #FamixJVMProfiler
]

{ #category : #accessing }
FamixJavaProfilerTraceGenerator class >> submetamodels [

	^ { FamixGenerator }
]

{ #category : #definition }
FamixJavaProfilerTraceGenerator >> defineClasses [ 
	javaProcess  := (builder
		          newClassNamed: #Process
		          comment:
		          'I hold the information of what happen when a method was executed in my Java program').
		
	profile := (builder
		            newClassNamed: #Profile
		            comment:
		            'I hold an entire profile obtain during the execution of a java program'). 
		
]

{ #category : #definition }
FamixJavaProfilerTraceGenerator >> defineProperties [ 
	
	javaProcess  property: #totalTime type: #String. 
	javaProcess  property: #totalTimeCPU type: #String. 	
	javaProcess  property: #nbInvocations type: #Number. 
	javaProcess property: #rawMthSignature type: #String. 
	javaProcess property: #relativeOrder type: #Number. 

	profile  property: #name type: #String.  
]

{ #category : #definition }
FamixJavaProfilerTraceGenerator >> defineRelations [
	
	(javaProcess  property: #subProcesses) -* (javaProcess  property: #parentProcess).
	(javaProcess property: #profile) *-<> (profile property: #profiling).
	(javaProcess property: #origin)
	*-
	((self remoteTrait: #TMethod withPrefix: #Famix) property: #JVMProcesses)
]
