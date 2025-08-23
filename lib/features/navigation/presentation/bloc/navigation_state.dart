part of 'navigation_bloc.dart';

sealed class NavigationState extends Equatable {
  const NavigationState();
}

final class NavigationInitial extends NavigationState {
  @override
  List<Object> get props => [];
}
