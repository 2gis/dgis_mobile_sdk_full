import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../search_result_item/star_rating_widget.dart';
import './directory_object_models.dart';
import './directory_object_view_model.dart';
import './directory_object_widget_theme.dart';

/// Abstract builder for customizing directory object view appearance.
///
/// Implement this interface to provide custom widgets for each section
/// of the directory object view.
abstract class DirectoryObjectWidgetBuilder {
  /// Builds the title section displaying the object name.
  Widget buildTitleWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the subtitle section displaying category or type.
  Widget buildSubtitleWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the rating section with star rating and review count.
  Widget buildRatingWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the distance indicator.
  Widget buildDistanceWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the short address section.
  Widget buildShortAddressWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the additional information section (e.g., porches count).
  Widget buildAdditionalInfoWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the alert section (e.g., "Closed" or "Opens at 9:00").
  Widget buildAlertWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the close button.
  Widget buildCloseButton(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the full address card.
  Widget buildFullAddressWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
    VoidCallback minimizeCard,
  );

  /// Builds the porches/entrances info section.
  /// Returns null if there are no porches to display.
  Widget? buildPorchesWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the working hours info section.
  /// Returns null if there are no working hours to display.
  Widget? buildWorkingHoursWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the contacts info section (phones, messengers).
  /// Returns null if there are no contacts to display.
  Widget? buildContactsWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );

  /// Builds the sites and social networks section.
  /// Returns null if there are no sites or social networks to display.
  Widget? buildSitesAndSocialNetworksWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  );
}

/// Default implementation of [DirectoryObjectWidgetBuilder].
class DefaultDirectoryObjectWidgetBuilder
    implements DirectoryObjectWidgetBuilder {
  const DefaultDirectoryObjectWidgetBuilder();

  @override
  Widget buildTitleWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final title = viewModel.title;
    if (title == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: theme.titleTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (viewModel.titleAddition != null) ...[
            const SizedBox(width: 4),
            Text(
              viewModel.titleAddition!,
              style: theme.titleAdditionTextStyle,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildSubtitleWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final subtitle = viewModel.subtitle;
    if (subtitle == null || subtitle.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        subtitle,
        style: theme.subtitleTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget buildRatingWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: viewModel.rating ?? 0,
          emptyStarColor: theme.emptyStarColor,
          filledStarColor: theme.filledStarColor,
        ),
        if (viewModel.rating != null) ...[
          const SizedBox(width: 4),
          Text(
            viewModel.rating!.toStringAsFixed(1),
            style: theme.ratingTextStyle,
          ),
        ],
        if (viewModel.reviewsCount != null) ...[
          const SizedBox(width: 4),
          Text(
            viewModel.reviewsCount!,
            style: theme.ratingCountTextStyle,
          ),
        ],
      ],
    );
  }

  @override
  Widget buildDistanceWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final distance = viewModel.distance;
    if (distance == null || distance.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      distance,
      style: theme.distanceTextStyle,
    );
  }

  @override
  Widget buildShortAddressWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final shortAddress = viewModel.shortAddress;
    if (shortAddress == null || shortAddress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        shortAddress,
        style: theme.shortAddressTextStyle,
      ),
    );
  }

  @override
  Widget buildAdditionalInfoWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final porchesCount = viewModel.porchesCount;
    if (porchesCount == null || porchesCount.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        porchesCount,
        style: theme.additionalInfoTextStyle,
      ),
    );
  }

  @override
  Widget buildAlertWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final workingHours = viewModel.workingHours;
    if (workingHours == null || workingHours.shortTitle.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        workingHours.shortTitle,
        style: workingHours.isOpenSoon
            ? theme.lowAlertTextStyle
            : theme.highAlertTextStyle,
      ),
    );
  }

  @override
  Widget buildCloseButton(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: theme.closeButtonBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: viewModel.onDismiss,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            Icons.close,
            size: 12,
            color: theme.closeButtonIconColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildFullAddressWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
    VoidCallback minimizeCard,
  ) {
    final mainLine = viewModel.fullAddressMainLine;
    final secondaryLine = viewModel.fullAddressSecondaryLine;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.cardCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              if (mainLine != null) {
                Clipboard.setData(ClipboardData(text: mainLine));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mainLine != null)
                    Text(
                      mainLine,
                      style: theme.fullAddressMainLineTextStyle,
                    ),
                  if (secondaryLine != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        secondaryLine,
                        style: theme.fullAddressSecondaryLineTextStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (viewModel.entrancesButtonLabel != null &&
              viewModel.onShowEntrances != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16, top: 2),
              child: Material(
                color: theme.tertiaryBackgroundColor,
                borderRadius: BorderRadius.circular(theme.cardCornerRadius),
                child: InkWell(
                  onTap: () {
                    minimizeCard();
                    final entrances = viewModel.entrances;
                    if (entrances != null) {
                      viewModel.onShowEntrances!(entrances);
                    }
                  },
                  borderRadius: BorderRadius.circular(theme.cardCornerRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      viewModel.entrancesButtonLabel!,
                      style: theme.fullAddressMainLineTextStyle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget? buildPorchesWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final porches = viewModel.porches;
    final porchesCount = viewModel.porchesCount;
    final porchesPrefix = viewModel.porchesPrefix;

    if (porches == null || porchesCount == null || porchesPrefix == null) {
      return null;
    }

    return _PorchesInfoWidget(
      porches: porches,
      porchesCount: porchesCount,
      porchesPrefix: porchesPrefix,
      theme: theme,
    );
  }

  @override
  Widget? buildWorkingHoursWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final workingHours = viewModel.workingHours;
    if (workingHours == null) return null;

    return _WorkingHoursInfoWidget(
      workingHours: workingHours,
      theme: theme,
    );
  }

  @override
  Widget? buildContactsWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final contacts = viewModel.contacts;
    if (contacts == null) return null;

    final phones = contacts.where((c) => c.type.isPhone).toList();
    final messengers = contacts.where((c) => c.type.isMessenger).toList();

    if (phones.isEmpty && messengers.isEmpty) {
      return null;
    }

    return _ContactsInfoWidget(
      phones: phones,
      messengers: messengers,
      contactsTitle: viewModel.contactsTitle,
      copyButtonLabel: viewModel.copyButtonLabel,
      expandButtonLabel: viewModel.expandButtonLabel,
      theme: theme,
    );
  }

  @override
  Widget? buildSitesAndSocialNetworksWidget(
    DirectoryObjectViewModel viewModel,
    DirectoryObjectWidgetTheme theme,
  ) {
    final contacts = viewModel.contacts;
    if (contacts == null) return null;

    final websites = contacts.where((c) => c.type.isWebsite).toList();
    final socialMedia = contacts.where((c) => c.type.isSocialMedia).toList();

    if (websites.isEmpty && socialMedia.isEmpty) {
      return null;
    }

    return _SitesAndSocialMediaWidget(
      websites: websites,
      socialMedia: socialMedia,
      title: viewModel.websitesSocialNetworksTitle,
      copyButtonLabel: viewModel.copyButtonLabel,
      expandButtonLabel: viewModel.expandButtonLabel,
      theme: theme,
    );
  }
}

/// Widget for displaying porches/entrances information.
class _PorchesInfoWidget extends StatefulWidget {
  final List<PorchItem> porches;
  final String porchesCount;
  final String porchesPrefix;
  final DirectoryObjectWidgetTheme theme;

  const _PorchesInfoWidget({
    required this.porches,
    required this.porchesCount,
    required this.porchesPrefix,
    required this.theme,
  });

  @override
  State<_PorchesInfoWidget> createState() => _PorchesInfoWidgetState();
}

class _PorchesInfoWidgetState extends State<_PorchesInfoWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.porches.length;
    final canExpand = count > 1;

    return GestureDetector(
      onTap:
          canExpand ? () => setState(() => _isExpanded = !_isExpanded) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(widget.theme.cardCornerRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.porchesPrefix} ${widget.porchesCount}',
                    style: widget.theme.porchesTitleTextStyle,
                  ),
                ),
                if (canExpand)
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: widget.theme.expandButtonColor,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (count == 1)
              _buildPorchRow(widget.porches.first)
            else if (_isExpanded)
              ...widget.porches.asMap().entries.map((entry) {
                return Column(
                  children: [
                    if (entry.key > 0)
                      Divider(color: widget.theme.dividerColor, height: 1),
                    _buildPorchRow(entry.value),
                  ],
                );
              })
            else
              _buildPorchRow(widget.porches.first),
          ],
        ),
      ),
    );
  }

  Widget _buildPorchRow(PorchItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: item.hasNumber ? 105 : null,
            child: Text(
              item.title,
              style: widget.theme.porchTitleTextStyle,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              item.apartments,
              style: widget.theme.porchApartmentsTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying working hours information.
class _WorkingHoursInfoWidget extends StatelessWidget {
  final WorkingHoursData workingHours;
  final DirectoryObjectWidgetTheme theme;

  const _WorkingHoursInfoWidget({
    required this.workingHours,
    required this.theme,
  });

  Color _getAlertColor() {
    switch (workingHours.alertLevel) {
      case WorkingHoursAlertLevel.low:
        return theme.workingHoursLowAlertColor;
      case WorkingHoursAlertLevel.medium:
        return theme.workingHoursMediumAlertColor;
      case WorkingHoursAlertLevel.high:
        return theme.workingHoursHighAlertColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFullWorkingHours =
        !workingHours.isUniformDaily && !workingHours.isOpen24x7;

    return GestureDetector(
      onTap: hasFullWorkingHours ? () => _showWorkingHoursSheet(context) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(theme.cardCornerRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 24,
              color: _getAlertColor(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workingHours.mediumTitle,
                      style: theme.workingHoursScheduleTextStyle,
                    ),
                    if (workingHours.mediumSubtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          workingHours.mediumSubtitle!,
                          style: theme.workingHoursBreakTextStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasFullWorkingHours)
              Icon(
                Icons.chevron_right,
                size: 14,
                color: theme.expandButtonColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showWorkingHoursSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      builder: (context) => _WorkingHoursSheet(
        workingHours: workingHours,
        theme: theme,
      ),
    );
  }
}

/// Bottom sheet for full working hours display.
class _WorkingHoursSheet extends StatelessWidget {
  final WorkingHoursData workingHours;
  final DirectoryObjectWidgetTheme theme;

  const _WorkingHoursSheet({
    required this.workingHours,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workingHours.scheduleLabel,
                  style: theme.titleTextStyle,
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.closeButtonBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: theme.closeButtonIconColor,
                    ),
                  ),
                ),
              ],
            ),
            ...workingHours.full.asMap().entries.map((entry) {
              return Column(
                children: [
                  if (entry.key > 0)
                    Divider(color: theme.dividerColor, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 32,
                          child: Text(
                            entry.value.days,
                            style: theme.workingHoursScheduleTextStyle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.title,
                                style: theme.workingHoursScheduleTextStyle,
                              ),
                              if (entry.value.subtitle != null)
                                Text(
                                  entry.value.subtitle!,
                                  style: theme.workingHoursBreakTextStyle,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying contacts (phones and messengers).
class _ContactsInfoWidget extends StatelessWidget {
  final List<ContactData> phones;
  final List<ContactData> messengers;
  final String contactsTitle;
  final String copyButtonLabel;
  final String? expandButtonLabel;
  final DirectoryObjectWidgetTheme theme;

  const _ContactsInfoWidget({
    required this.phones,
    required this.messengers,
    required this.contactsTitle,
    required this.copyButtonLabel,
    required this.theme,
    this.expandButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.cardCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phones.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                contactsTitle,
                style: theme.contactsTitleTextStyle,
              ),
            ),
            ...phones.map(_buildContactRow),
          ],
          if (messengers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Divider(color: theme.dividerColor, height: 1),
            ),
            ...messengers.map(_buildContactRow),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(ContactData contact) {
    final hasComment = contact.comment != null && contact.comment!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final uri = contact.launchUri;
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: contact.value));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment:
              hasComment ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: hasComment ? 10 : 0),
              child: Icon(
                _getContactIcon(contact.type),
                size: 24,
                color: theme.contactIconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.title,
                    style: theme.contactTitleTextStyle,
                  ),
                  if (hasComment) ...[
                    const SizedBox(height: 4),
                    _ExpandableCommentText(
                      text: contact.comment!,
                      textStyle: theme.contactCommentTextStyle,
                      buttonText: expandButtonLabel ?? '',
                      buttonTextStyle: theme.contactExpandButtonTextStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContactIcon(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return Icons.phone;
      case ContactType.email:
        return Icons.email;
      case ContactType.whatsapp:
      case ContactType.telegram:
      case ContactType.viber:
        return Icons.chat;
      default:
        return Icons.link;
    }
  }
}

/// Widget for displaying websites and social media links.
class _SitesAndSocialMediaWidget extends StatelessWidget {
  final List<ContactData> websites;
  final List<ContactData> socialMedia;
  final String title;
  final String copyButtonLabel;
  final String? expandButtonLabel;
  final DirectoryObjectWidgetTheme theme;

  const _SitesAndSocialMediaWidget({
    required this.websites,
    required this.socialMedia,
    required this.title,
    required this.copyButtonLabel,
    required this.theme,
    this.expandButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final leadingOffset = websites.isEmpty ? 16.0 : 52.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.cardCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              title,
              style: theme.contactsTitleTextStyle,
            ),
          ),
          if (websites.isNotEmpty) ...websites.map(_buildSiteRow),
          if (socialMedia.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: leadingOffset,
                top: 16,
                bottom: 16,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...socialMedia.map(_buildSocialMediaButton),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSiteRow(ContactData contact) {
    final hasComment = contact.comment != null && contact.comment!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final uri = contact.launchUri;
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: contact.value));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getSiteIcon(contact.type),
              size: 24,
              color: theme.contactIconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      contact.title,
                      style: theme.contactTitleTextStyle,
                    ),
                  ),
                  if (hasComment) ...[
                    const SizedBox(height: 4),
                    _ExpandableCommentText(
                      text: contact.comment!,
                      textStyle: theme.contactCommentTextStyle,
                      buttonText: expandButtonLabel ?? '',
                      buttonTextStyle: theme.contactExpandButtonTextStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaButton(ContactData contact) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: theme.socialMediaButtonBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            final uri = contact.launchUri;
            if (uri == null) return;
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 52,
            height: 40,
            child: Icon(
              _getSocialMediaIcon(contact.type),
              size: 24,
              color: theme.contactIconColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSiteIcon(ContactType type) {
    switch (type) {
      case ContactType.email:
        return Icons.email;
      case ContactType.website:
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  IconData _getSocialMediaIcon(ContactType type) {
    switch (type) {
      case ContactType.vkontakte:
        return Icons.public;
      case ContactType.twitter:
        return Icons.public;
      case ContactType.youtube:
        return Icons.play_circle;
      case ContactType.telegram:
      case ContactType.telegramChannel:
        return Icons.send;
      case ContactType.linkedin:
        return Icons.work;
      case ContactType.pinterest:
        return Icons.push_pin;
      default:
        return Icons.public;
    }
  }
}

/// Widget for expandable comment text.
class _ExpandableCommentText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final String buttonText;
  final TextStyle buttonTextStyle;

  const _ExpandableCommentText({
    required this.text,
    required this.textStyle,
    required this.buttonText,
    required this.buttonTextStyle,
  });

  @override
  State<_ExpandableCommentText> createState() => _ExpandableCommentTextState();
}

class _ExpandableCommentTextState extends State<_ExpandableCommentText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return Text(
        widget.text,
        style: widget.textStyle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: widget.text, style: widget.textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: widget.textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = true),
                child: Text(
                  widget.buttonText,
                  style: widget.buttonTextStyle,
                ),
              ),
            ],
          );
        }

        return Text(
          widget.text,
          style: widget.textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
