import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.orderType, required this.orders});
  final String orderType;
  final List<Map<String, String>> orders;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return widget.orders.isEmpty
        ? Center(child: Text("暂无${widget.orderType}"))
        : ListView.builder(
            itemCount: widget.orders.length,
            itemBuilder: (context, index) {
              final order = widget.orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    widget.orderType == "服务中订单"
                        ? Icons.directions_bike
                        : Icons.done,
                    color: widget.orderType == "服务中订单"
                        ? Colors.orange
                        : Colors.green,
                  ),
                  title: Text(order["title"]!),
                  subtitle: Text(order["time"]!),
                  trailing: Text(
                    widget.orderType == "服务中订单" ? "进行中" : "已完成",
                    style: TextStyle(
                      color: widget.orderType == "服务中订单"
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  onTap: () {
                    // 点击查看订单详情
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(order["title"]!),
                        content: Text(
                            "回收时间：${order["time"]!}\n回收地址：${order["address"]!}"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("关闭"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
