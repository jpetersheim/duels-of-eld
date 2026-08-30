extends ScrollContainer

@onready var log_container: VBoxContainer = $LogContainer

# Maximum log entries to keep in memory (prevents performance lag)
@export var max_entries: int = 100

## Adds a simple text entry or rich BBCode text to the log
func add_log(text: String) -> void:
	# Create a RichTextLabel dynamically for each log line
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Assign the log message (supports BBCode like [color=red]Damage[/color])
	label.text = text
	
	log_container.add_child(label)
	
	# Remove old entries if maximum capacity is exceeded
	if log_container.get_child_count() > max_entries:
		var oldest_child = log_container.get_child(0)
		oldest_child.queue_free()
	
	# Defer scrolling to the bottom until after the UI updates frame layout
	call_deferred("_scroll_to_bottom")

func _scroll_to_bottom() -> void:
	# Sets scroll position to max vertical height
	scroll_vertical = int(get_v_scroll_bar().max_value)
