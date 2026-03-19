import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'widgets/prototype_camera_preview.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _currentStep = 0;
  bool _cameraEnabled = false;
  bool _isAnalyzing = false;
  double _workloadScore = 7;

  Future<void> _goNext() async {
    if (_isAnalyzing) {
      return;
    }

    if (_currentStep == 2) {
      setState(() {
        _isAnalyzing = true;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzing = false;
        _currentStep = 3;
      });
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    context.go('/results');
  }

  void _goBack() {
    if (_isAnalyzing || _currentStep == 0) {
      return;
    }
    setState(() {
      _currentStep -= 1;
    });
  }

  void _skipStepOne() {
    if (_currentStep != 0) {
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CheckinStepper(currentStep: _currentStep),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: _buildCurrentStep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _StepContainer(
          key: const ValueKey('step-1'),
          child: _StepOneContent(
            cameraEnabled: _cameraEnabled,
            onCameraChanged: (value) {
              setState(() {
                _cameraEnabled = value;
              });
            },
            onSkip: _skipStepOne,
            onContinue: _goNext,
          ),
        );
      case 1:
        return _StepContainer(
          key: const ValueKey('step-2'),
          child: _VoiceQuestionStep(
            stepLabel: 'Étape 2 sur 4 — Question 1',
            question:
                'Comment décririez-vous votre énergie ces dernières semaines ?',
            timerLabel: '0:38',
            onBack: _goBack,
            onContinue: _goNext,
            continueLabel: 'Continuer →',
          ),
        );
      case 2:
        return _StepContainer(
          key: const ValueKey('step-3'),
          child: _VoiceQuestionStep(
            stepLabel: 'Étape 3 sur 4 — Question 2',
            question:
                'Avez-vous réussi à déconnecter du travail ces derniers jours ?',
            timerLabel: '0:42',
            onBack: _goBack,
            onContinue: _goNext,
            continueLabel: _isAnalyzing ? 'Analyse...' : 'Continuer →',
            isLoading: _isAnalyzing,
            analysisText: '✓ Analyse en cours...',
          ),
        );
      case 3:
      default:
        return _StepContainer(
          key: const ValueKey('step-4'),
          child: _StepFourContent(
            value: _workloadScore,
            onValueChanged: (value) {
              setState(() {
                _workloadScore = value;
              });
            },
            onBack: _goBack,
            onFinish: _goNext,
          ),
        );
    }
  }
}

class _StepContainer extends StatelessWidget {
  const _StepContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child
          .animate()
          .fadeIn(duration: 280.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }
}

class _CheckinStepper extends StatelessWidget {
  const _CheckinStepper({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          return Row(
            children: List.generate(4, (index) {
              final done = index < currentStep;
              final active = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: compact ? 30 : 36,
                      height: compact ? 30 : 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || active
                            ? AppColors.violet
                            : AppColors.background,
                        border: Border.all(
                          color: done || active
                              ? AppColors.violet
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: done || active
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: index < currentStep
                              ? AppColors.violet
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _StepOneContent extends StatelessWidget {
  const _StepOneContent({
    required this.cameraEnabled,
    required this.onCameraChanged,
    required this.onSkip,
    required this.onContinue,
  });

  final bool cameraEnabled;
  final ValueChanged<bool> onCameraChanged;
  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étape 1 sur 4 — Analyse faciale',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Switch.adaptive(
              value: cameraEnabled,
              activeTrackColor: AppColors.stableGreenLight,
              activeThumbColor: AppColors.stableGreen,
              onChanged: onCameraChanged,
            ),
            const SizedBox(width: 10),
            Text(
              'Caméra optionnelle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (cameraEnabled)
          Container(
            width: 560,
            constraints: const BoxConstraints(maxWidth: double.infinity),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LiveDot(),
                      const SizedBox(width: 8),
                      Text(
                        'Caméra active',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const PrototypeCameraPreview(),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cards,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.violet,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode prototype: superposition visuelle statique (contour visage, yeux, bouche).',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Compte à rebours : 0:28',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          Container(
            width: 560,
            constraints: const BoxConstraints(maxWidth: double.infinity),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Active la caméra si tu veux enrichir le check-in avec des métriques faciales (simulation).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.violetLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Aucune image n\'est sauvegardée. Seulement des métriques numériques.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: const Text('Passer'),
            ),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continuer →'),
            ),
          ],
        ),
      ],
    );
  }
}

class _VoiceQuestionStep extends StatelessWidget {
  const _VoiceQuestionStep({
    required this.stepLabel,
    required this.question,
    required this.timerLabel,
    required this.onBack,
    required this.onContinue,
    required this.continueLabel,
    this.isLoading = false,
    this.analysisText,
  });

  final String stepLabel;
  final String question;
  final String timerLabel;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool isLoading;
  final String? analysisText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stepLabel, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(question, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 16),
        Container(
          width: 520,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cards,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const _AudioWave(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.riskOrangeLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.riskOrange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: AppColors.riskOrange),
                    const SizedBox(width: 8),
                    Text(
                      '● ENREG',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF633806),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Timer : $timerLabel',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Parlez normalement, prenez votre temps.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (analysisText != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (isLoading) const SizedBox(width: 8),
              Text(
                analysisText!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.stableGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: isLoading ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: const Text('← Retour'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : onContinue,
              child: Text(continueLabel),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepFourContent extends StatelessWidget {
  const _StepFourContent({
    required this.value,
    required this.onValueChanged,
    required this.onBack,
    required this.onFinish,
  });

  final double value;
  final ValueChanged<double> onValueChanged;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final badge = _workloadBadge(value.round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étape 4 sur 4 — Charge perçue',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        Text(
          'Comment évaluez-vous votre charge de travail ce mois ?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 18),
        Container(
          width: 560,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: value,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.violet,
                inactiveColor: AppColors.violetLight,
                label: value.round().toString(),
                onChanged: onValueChanged,
              ),
              Text(
                'Valeur: ${value.round()} / 10',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: badge.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badge.border),
                ),
                child: Text(
                  badge.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: badge.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: const Text('← Retour'),
            ),
            ElevatedButton(
              onPressed: onFinish,
              child: const Text('Terminer mon check-in ✓'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AudioWave extends StatelessWidget {
  const _AudioWave();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(16, (index) {
          final baseHeight = 10 + ((index * 7) % 34);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Align(
              alignment: Alignment.bottomCenter,
              child:
                  Container(
                        width: 5,
                        height: baseHeight.toDouble(),
                        decoration: BoxDecoration(
                          color: AppColors.violet.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scaleY(
                        begin: 0.35,
                        end: 1.15,
                        alignment: Alignment.bottomCenter,
                        delay: (index * 80).ms,
                        duration: (450 + (index % 5) * 70).ms,
                        curve: Curves.easeInOut,
                      ),
            ),
          );
        }),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.stableGreen,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.35, end: 1, duration: 800.ms)
        .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15));
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.background,
    required this.text,
    required this.border,
  });

  final String label;
  final Color background;
  final Color text;
  final Color border;
}

_BadgeStyle _workloadBadge(int value) {
  if (value <= 3) {
    return const _BadgeStyle(
      label: 'Légère 🟢',
      background: AppColors.stableGreenLight,
      text: Color(0xFF085041),
      border: AppColors.stableGreen,
    );
  }
  if (value <= 6) {
    return const _BadgeStyle(
      label: 'Modérée 🟡',
      background: AppColors.riskOrangeLight,
      text: Color(0xFF633806),
      border: AppColors.riskOrange,
    );
  }
  return const _BadgeStyle(
    label: 'Intense 🔴',
    background: AppColors.criticalRedLight,
    text: Color(0xFF712B13),
    border: AppColors.criticalRed,
  );
}
