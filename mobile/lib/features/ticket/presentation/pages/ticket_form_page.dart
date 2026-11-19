import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/customer_picker_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../master/domain/entities/area.dart';
import '../../../master/domain/entities/customer.dart';
import '../../../master/domain/entities/issue_type.dart';
import '../../../master/domain/entities/odp.dart';
import '../../../master/domain/entities/priority.dart';
import '../../../master/domain/usecases/get_customers.dart';
import '../../domain/entities/ticket.dart';
import '../bloc/ticket_form_bloc.dart';
import '../bloc/ticket_form_event.dart';
import '../bloc/ticket_form_state.dart';

class TicketFormPage extends StatelessWidget {
  final Ticket? ticket; // jika null -> Create, jika ada -> Edit

  const TicketFormPage({super.key, this.ticket});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TicketFormBloc>(
      create: (context) =>
          getIt<TicketFormBloc>()..add(const LoadMasterFormData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(ticket == null ? 'Buat Tiket Baru' : 'Edit Tiket'),
        ),
        body: BlocConsumer<TicketFormBloc, TicketFormState>(
          listener: (context, state) {
            if (state is TicketFormSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isUpdate
                        ? 'Tiket berhasil diperbarui'
                        : 'Tiket berhasil dibuat: ${state.ticket.ticketNo}',
                  ),
                ),
              );
              context.pop(true);
            } else if (state is TicketFormDataLoaded &&
                state.submitErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.submitErrorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TicketFormDataLoading) {
              return const LoadingView(message: 'Memuat data formulir...');
            }

            if (state is TicketFormDataError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<TicketFormBloc>().add(
                    const LoadMasterFormData(),
                  );
                },
              );
            }

            if (state is TicketFormDataLoaded) {
              return _TicketFormContent(
                ticket: ticket,
                areas: state.areas,
                odps: state.odps,
                issueTypes: state.issueTypes,
                priorities: state.priorities,
                isLoadingOdps: state.isLoadingOdps,
                isSubmitting: state.isSubmitting,
                fieldErrors: state.fieldErrors,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TicketFormContent extends StatefulWidget {
  final Ticket? ticket;
  final List<Area> areas;
  final List<Odp> odps;
  final List<IssueType> issueTypes;
  final List<Priority> priorities;
  final bool isLoadingOdps;
  final bool isSubmitting;
  final Map<String, String>? fieldErrors;

  const _TicketFormContent({
    this.ticket,
    required this.areas,
    required this.odps,
    required this.issueTypes,
    required this.priorities,
    required this.isLoadingOdps,
    required this.isSubmitting,
    this.fieldErrors,
  });

  @override
  State<_TicketFormContent> createState() => _TicketFormContentState();
}

class _TicketFormContentState extends State<_TicketFormContent> {
  final _formKey = GlobalKey<FormState>();

  Customer? _selectedCustomer;
  Area? _selectedArea;
  Odp? _selectedOdp;
  IssueType? _selectedIssueType;
  Priority? _selectedPriority;

  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.ticket?.description ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.ticket?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.ticket?.longitude?.toString() ?? '',
    );

    // Inisialisasi initial selection jika mode edit
    if (widget.ticket != null) {
      _selectedCustomer = Customer(
        id: widget.ticket!.customerId,
        tenantId: widget.ticket!.tenantId ?? 0,
        name: widget.ticket!.customerName ?? '',
        areaId: widget.ticket!.areaId,
      );

      final matchingAreas = widget.areas.where(
        (a) => a.id == widget.ticket!.areaId,
      );
      if (matchingAreas.isNotEmpty) {
        _selectedArea = matchingAreas.first;
        context.read<TicketFormBloc>().add(
          AreaSelectedEvent(_selectedArea!.id),
        );
      }

      final matchingIssues = widget.issueTypes.where(
        (i) => i.id == widget.ticket!.issueTypeId,
      );
      if (matchingIssues.isNotEmpty) {
        _selectedIssueType = matchingIssues.first;
      }

      final matchingPriorities = widget.priorities.where(
        (p) => p.id == widget.ticket!.priorityId,
      );
      if (matchingPriorities.isNotEmpty) {
        _selectedPriority = matchingPriorities.first;
      }
    }
  }

  @override
  void didUpdateWidget(covariant _TicketFormContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika ODP baru selesai dimuat dan ada initial odpId
    if (widget.ticket?.odpId != null &&
        _selectedOdp == null &&
        widget.odps.isNotEmpty) {
      final matchingOdps = widget.odps.where(
        (o) => o.id == widget.ticket!.odpId,
      );
      if (matchingOdps.isNotEmpty) {
        setState(() {
          _selectedOdp = matchingOdps.first;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pelanggan wajib dipilih')));
      return;
    }

    double? lat = double.tryParse(_latitudeController.text.trim());
    double? lng = double.tryParse(_longitudeController.text.trim());

    if ((lat != null && lng == null) || (lat == null && lng != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude dan longitude harus diisi berpasangan'),
        ),
      );
      return;
    }

    context.read<TicketFormBloc>().add(
      SubmitTicketForm(
        ticketId: widget.ticket?.id,
        customerId: _selectedCustomer!.id,
        areaId: _selectedArea!.id,
        odpId: _selectedOdp?.id,
        issueTypeId: _selectedIssueType!.id,
        priorityId: _selectedPriority!.id,
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pemilih Pelanggan
          Text(
            'Pelanggan',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.isSubmitting
                ? null
                : () async {
                    final selected =
                        await CustomerPickerBottomSheet.show<Customer>(
                          context: context,
                          title: 'Pilih Pelanggan',
                          onSearch: (query) async {
                            final res = await getIt<GetCustomers>().call(
                              search: query,
                            );
                            return res.fold(
                              (f) => [],
                              (paginated) => paginated.data,
                            );
                          },
                          itemTitle: (c) => c.name,
                          itemSubtitle: (c) =>
                              c.phone != null ? 'Telp: ${c.phone}' : c.address,
                        );

                    if (selected != null) {
                      setState(() {
                        _selectedCustomer = selected;
                        // Auto-fill area jika pelanggan sudah terikat area
                        final matchingAreas = widget.areas.where(
                          (a) => a.id == selected.areaId,
                        );
                        if (matchingAreas.isNotEmpty) {
                          _selectedArea = matchingAreas.first;
                          _selectedOdp = null;
                          context.read<TicketFormBloc>().add(
                            AreaSelectedEvent(_selectedArea!.id),
                          );
                        }
                      });
                    }
                  },
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: 'Pilih Pelanggan...',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                errorText: widget.fieldErrors?['customer_id'],
              ),
              child: Text(
                _selectedCustomer != null
                    ? _selectedCustomer!.name
                    : 'Pilih Pelanggan...',
                style: _selectedCustomer != null
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown Area
          AppDropdownField<Area>(
            label: 'Area Jaringan',
            hint: 'Pilih Area...',
            prefixIcon: const Icon(Icons.map_outlined),
            value: _selectedArea,
            items: widget.areas,
            itemLabel: (a) => a.name,
            errorMessage: widget.fieldErrors?['area_id'],
            enabled: !widget.isSubmitting,
            validator: (val) => val == null ? 'Area wajib dipilih' : null,
            onChanged: (area) {
              setState(() {
                _selectedArea = area;
                _selectedOdp = null;
              });
              if (area != null) {
                context.read<TicketFormBloc>().add(AreaSelectedEvent(area.id));
              }
            },
          ),
          const SizedBox(height: 16),

          // Dropdown ODP (bergantung pada area terpilih)
          AppDropdownField<Odp>(
            label: 'Titik ODP (Opsional)',
            hint: _selectedArea == null
                ? 'Pilih area terlebih dahulu'
                : 'Pilih ODP...',
            prefixIcon: const Icon(Icons.device_hub_outlined),
            value: _selectedOdp,
            items: widget.odps,
            itemLabel: (o) => o.code,
            isLoading: widget.isLoadingOdps,
            errorMessage: widget.fieldErrors?['odp_id'],
            enabled: !widget.isSubmitting && _selectedArea != null,
            emptyMessage: 'Tidak ada ODP di area ini',
            onChanged: (odp) {
              setState(() {
                _selectedOdp = odp;
              });
            },
          ),
          const SizedBox(height: 16),

          // Dropdown Jenis Gangguan
          AppDropdownField<IssueType>(
            label: 'Jenis Gangguan',
            hint: 'Pilih Jenis Gangguan...',
            prefixIcon: const Icon(Icons.warning_amber_outlined),
            value: _selectedIssueType,
            items: widget.issueTypes,
            itemLabel: (it) => it.name,
            errorMessage: widget.fieldErrors?['issue_type_id'],
            enabled: !widget.isSubmitting,
            validator: (val) =>
                val == null ? 'Jenis gangguan wajib dipilih' : null,
            onChanged: (val) => setState(() => _selectedIssueType = val),
          ),
          const SizedBox(height: 16),

          // Dropdown Prioritas
          AppDropdownField<Priority>(
            label: 'Tingkat Prioritas',
            hint: 'Pilih Prioritas...',
            prefixIcon: const Icon(Icons.flag_outlined),
            value: _selectedPriority,
            items: widget.priorities,
            itemLabel: (p) => '${p.name} (SLA: ${p.slaHours} jam)',
            errorMessage: widget.fieldErrors?['priority_id'],
            enabled: !widget.isSubmitting,
            validator: (val) => val == null ? 'Prioritas wajib dipilih' : null,
            onChanged: (val) => setState(() => _selectedPriority = val),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          AppTextField(
            label: 'Deskripsi Gangguan',
            hint:
                'Jelaskan keluhan pelanggan secara rinci (min. 10 karakter)...',
            controller: _descriptionController,
            maxLines: 4,
            enabled: !widget.isSubmitting,
            errorText: widget.fieldErrors?['description'],
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Deskripsi wajib diisi';
              }
              if (val.trim().length < 10) {
                return 'Deskripsi minimal 10 karakter';
              }
              if (val.trim().length > 1000) {
                return 'Deskripsi maksimal 1000 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Koordinat Latitude & Longitude (Opsional)
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Latitude (Opsional)',
                  hint: '-7.2625',
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  enabled: !widget.isSubmitting,
                  errorText: widget.fieldErrors?['latitude'],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final num = double.tryParse(val.trim());
                    if (num == null || num < -90 || num > 90) {
                      return 'Antara -90 s/d 90';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Longitude (Opsional)',
                  hint: '112.7483',
                  controller: _longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  enabled: !widget.isSubmitting,
                  errorText: widget.fieldErrors?['longitude'],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final num = double.tryParse(val.trim());
                    if (num == null || num < -180 || num > 180) {
                      return 'Antara -180 s/d 180';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Submit
          AppButton(
            text: widget.ticket == null ? 'Simpan Tiket' : 'Perbarui Tiket',
            isLoading: widget.isSubmitting,
            onPressed: widget.isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
