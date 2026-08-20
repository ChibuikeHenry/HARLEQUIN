import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/base_viewmodel.dart';

/// Binds a [BaseViewModel] to a View for the widget lifetime.
class ViewModelBuilder<T extends BaseViewModel> extends StatefulWidget {
  const ViewModelBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  final T Function() create;
  final Widget Function(BuildContext context, T viewModel) builder;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends BaseViewModel>
    extends State<ViewModelBuilder<T>> {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.create();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.init();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: _viewModel,
      child: Consumer<T>(
        builder: (context, viewModel, _) =>
            widget.builder(context, viewModel),
      ),
    );
  }
}
