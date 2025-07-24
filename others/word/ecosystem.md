# ecosystem

这段代码是Godot游戏引擎中的GDScript，用于在一个静态体上生成一个生态系统的视觉表示。具体来说，这段代码的主要功能是在一个圆形区域内随机分布森林斑块，并在这些斑块中实例化树木。下面是逐步分解和详细解释：

1. **函数定义**：
   - `spawn_ecosystem()`：这是一个函数，用于生成生态系统的视觉表示。

2. **前置检查**：
   - `if not tree_scene or polygon.polygon.size() < 2: return`：首先检查是否有有效的树场景资源（`tree_scene`），以及多边形是否至少有两个顶点。如果没有，函数直接返回，不进行任何操作。

3. **清理旧对象**：
   - `for child in get_children(): if child.name.begins_with("PlanetTree_") or child.name.begins_with("SurfaceMark_"): child.queue_free()`：遍历所有子节点，如果子节点的名称以"PlanetTree_"或"SurfaceMark_"开头，则将其从场景树中移除。这是为了在每次生成新的生态系统时，先清理掉之前生成的树和标记。

4. **准备变量**：
   - `var points: Array = polygon.polygon`：获取多边形的顶点数组。
   - `var patch_len = int(points.size() * forest_patch_ratio)`：根据多边形的顶点数和`forest_patch_ratio`计算每个森林斑块的长度。
   - `var forest_indices = []`：初始化一个数组，用于存储属于森林斑块的顶点索引。
   - `var patch_centers = []`：初始化一个数组，用于存储每个森林斑块的中心顶点索引。

5. **随机分布森林斑块**：
   - `for p in range(forest_patch_count): var center = random.randi_range(0, points.size()-1) patch_centers.append(center)`：根据`forest_patch_count`生成指定数量的森林斑块，并随机选择每个斑块的中心顶点。

6. **记录森林斑块的顶点索引**：
   - `for center in patch_centers: for offset in range(-patch_len / float(2), patch_len / float(2)): var idx = (center + offset + points.size()) % points.size() forest_indices.append(idx)`：对于每个森林斑块的中心顶点，计算出该斑块的顶点索引范围，并将这些索引添加到`forest_indices`中。使用取模运算确保索引在有效范围内循环。

7. **标记森林和平原区域**：
   - `for i in range(points.size()-1): is_forest.append(i in forest_indices)`：创建一个布尔数组`is_forest`，用于标记多边形的每个顶点是否属于森林斑块。
   - `if visualization:`：如果启用了可视化选项，则根据`is_forest`数组创建标记，显示每个顶点是属于森林区域还是平原区域。
     - `var mark = ColorRect.new()`：创建一个新的颜色矩形。
     - `mark.name = "SurfaceMark_%d" % i`：为标记设置名称。
     - `mark.color = forest_color if is_forest[i] else plain_color`：根据顶点是否属于森林斑块来设置标记的颜色。
     - `mark.size = Vector2(8,8)`：设置标记的大小。
     - `mark.position = points[i] - Vector2(4,4)`：设置标记的位置，使其居中于顶点。
     - `mark.z_index = -5`：设置标记的层级，确保它位于多边形下方。
     - `add_child(mark)`：将标记添加到当前节点的子节点中。

8. **分布树木**：
   - `for i in range(points.size()-1): if not is_forest[i]: continue`：遍历多边形的所有顶点，如果顶点不是森林区域的一部分，则跳过。
   - `var vertex = points[i] var normal = vertex.normalized() var tree_pos = vertex + normal * tree_offset`：计算树的位置，使其浮动在多边形的顶点之上，距离为`tree_offset`。
   - `if last_tree_pos == null or tree_pos.distance_to(last_tree_pos) >= base_tree_spacing:`：检查当前树的位置是否与上一棵树的位置有足够的间距，避免树木过于密集。
     - `var tree = tree_scene.instantiate()`：实例化树的场景资源。
     - `tree.name = "PlanetTree_%d" % tree_id`：为树设置名称。
     - `tree.position = tree_pos`：设置树的位置。
     - `tree.rotation = normal.angle() + PI/2`：设置树的旋转角度，使其朝向多边形的外侧。
     - `add_child(tree)`：将树添加到当前节点的子节点中。
     - `last_tree_pos = tree_pos`：更新上一棵树的位置。
     - `tree_id += 1`：增加树的ID计数。

**总结**：
这段代码的主要功能是在一个静态体上生成一个生态系统的视觉表示，具体包括随机分布森林斑块，并在这些斑块中实例化树木。代码还提供了可视化选项，可以显示每个顶点是否属于森林区域。通过调整可调节参数，用户可以控制森林斑块的数量、密度、颜色等，以及树木的分布方式和外观。
