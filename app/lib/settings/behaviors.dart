import 'package:butterfly/cubits/settings.dart';
import 'package:butterfly/views/main.dart';
import 'package:butterfly/visualizer/sync.dart';
import 'package:butterfly/widgets/exact_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BehaviorsSettingsPage extends StatelessWidget {
  final bool inView;
  const BehaviorsSettingsPage({super.key, this.inView = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: inView ? Colors.transparent : null,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.behaviors),
          backgroundColor: inView ? Colors.transparent : null,
          automaticallyImplyLeading: !inView,
          actions: [
            if (!inView && !kIsWeb && isWindow()) ...[
              const VerticalDivider(),
              const WindowButtons()
            ]
          ],
        ),
        body: BlocBuilder<SettingsCubit, ButterflySettings>(
            builder: (context, state) {
          return ListView(
            children: [
              if (!kIsWeb)
                Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(AppLocalizations.of(context)!.connection,
                                style: Theme.of(context).textTheme.headline5),
                            const SizedBox(height: 16),
                            ListTile(
                              title:
                                  Text(AppLocalizations.of(context)!.syncMode),
                              leading: Icon(state.syncMode.getIcon()),
                              subtitle: Text(
                                  state.syncMode.getLocalizedName(context)),
                              onTap: () => _openSyncModeModal(context),
                            ),
                          ]),
                    )),
              Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(AppLocalizations.of(context)!.input,
                              style: Theme.of(context).textTheme.headline5),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: state.penOnlyInput,
                            title: Text(
                                AppLocalizations.of(context)!.penOnlyInput),
                            onChanged: (value) => context
                                .read<SettingsCubit>()
                                .changepenOnlyInput(value ?? false),
                          ),
                          CheckboxListTile(
                            value: state.inputGestures,
                            title: Text(
                                AppLocalizations.of(context)!.inputGestures),
                            onChanged: (value) => context
                                .read<SettingsCubit>()
                                .changeinputGestures(value ?? true),
                          ),
                        ]),
                  )),
              Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(AppLocalizations.of(context)!.sensitivity,
                              style: Theme.of(context).textTheme.headline5),
                          Text(AppLocalizations.of(context)!.sensitivityHint,
                              style: Theme.of(context).textTheme.subtitle2),
                          const SizedBox(height: 16),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(children: [
                                ExactSlider(
                                    min: 0,
                                    max: 100,
                                    value: state.touchSensitivity,
                                    header: Row(children: [
                                      const Icon(PhosphorIcons.handLight),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context)!
                                          .touchSensitivity),
                                    ]),
                                    onChanged: (value) {
                                      final cubit =
                                          context.read<SettingsCubit>();
                                      cubit.changeTouchSensitivity(value);
                                    }),
                                const SizedBox(height: 16),
                                ExactSlider(
                                    min: 0,
                                    max: 100,
                                    value: state.mouseSensitivity,
                                    header: Row(children: [
                                      const Icon(PhosphorIcons.mouseLight),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context)!
                                          .mouseSensitivity),
                                    ]),
                                    onChanged: (value) {
                                      final cubit =
                                          context.read<SettingsCubit>();
                                      cubit.changeMouseSensitivity(value);
                                    }),
                                const SizedBox(height: 16),
                                ExactSlider(
                                    min: 0,
                                    max: 100,
                                    value: state.penSensitivity,
                                    header: Row(children: [
                                      const Icon(PhosphorIcons.penLight),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context)!
                                          .penSensitivity),
                                    ]),
                                    onChanged: (value) {
                                      final cubit =
                                          context.read<SettingsCubit>();
                                      cubit.changePenSensitivity(value);
                                    }),
                                ExactSlider(
                                    min: 0,
                                    max: 50,
                                    defaultValue: 5,
                                    value: state.selectSensitivity,
                                    header: Row(children: [
                                      const Icon(PhosphorIcons.cursorLight),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context)!
                                          .selectSensitivity),
                                    ]),
                                    onChanged: (value) {
                                      final cubit =
                                          context.read<SettingsCubit>();
                                      cubit.changeSelectSensitivity(value);
                                    }),
                              ])),
                        ]),
                  )),
            ],
          );
        }));
  }

  Future<void> _openSyncModeModal(BuildContext context) => showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final settingsCubit = context.read<SettingsCubit>();
        void changeSyncMode(SyncMode syncMode) {
          settingsCubit.changeSyncMode(syncMode);
          Navigator.of(context).pop();
        }

        return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ListView(shrinkWrap: true, children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  AppLocalizations.of(context)!.syncMode,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ),
              ...SyncMode.values.map((syncMode) {
                return ListTile(
                  title: Text(syncMode.getLocalizedName(context)),
                  leading: Icon(syncMode.getIcon()),
                  selected: syncMode == settingsCubit.state.syncMode,
                  onTap: () => changeSyncMode(syncMode),
                );
              }),
              const SizedBox(height: 32),
            ]));
      });
}
