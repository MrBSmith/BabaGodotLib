extends Object
class_name Perf


static func benchmark(obj: Object, method_name: String, args := [], i := 10, j := 100, k := 1000) -> void:
	if !is_instance_valid(obj):
		push_error("The given object is null, abort benchmark")
		return
	
	if !obj.has_method(method_name):
		push_error("The given object %s doesn't have the given method %s" % [obj.get_class(), method_name])
		return
	
	print("Running method %s on %s with the given arguments: %s" % [obj.get_class(), method_name, str(args)])
	
	
	for nb in [i, j, k]:
		var time_before = Time.get_ticks_usec()
		
		for i in range(nb):
			obj.callv(method_name, args)
		
		var time_after = Time.get_ticks_usec()
		var delta := float(time_after - time_before)
		
		print("%d : took %f ms" % [nb, delta / 1000.0])
