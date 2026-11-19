import areaRepository from './areas.repository.js';
import odpRepository from './odps.repository.js';
import issueTypeRepository from './issue_types.repository.js';
import priorityRepository from './priorities.repository.js';
import customerRepository from './customers.repository.js';
import vendorRepository from './vendors.repository.js';
import { NotFoundError, ConflictError } from '../../utils/errors.js';

export class MasterService {
  async getAreas(tenantId) {
    return areaRepository.findByTenantId(tenantId);
  }

  async getAreaById(tenantId, id) {
    const area = await areaRepository.findByIdAndTenantId(id, tenantId);
    if (!area) {
      throw new NotFoundError('Area tidak ditemukan');
    }
    return area;
  }

  async createArea(tenantId, data) {
    return areaRepository.create(tenantId, data);
  }

  async updateArea(tenantId, id, data) {
    await this.getAreaById(tenantId, id);
    return areaRepository.update(id, tenantId, data);
  }

  async deleteArea(tenantId, id) {
    await this.getAreaById(tenantId, id);
    const isUsed = await areaRepository.isUsed(id, tenantId);
    if (isUsed) {
      throw new ConflictError('Area tidak dapat dihapus karena masih digunakan oleh data tiket, ODP, atau pelanggan');
    }
    return areaRepository.delete(id, tenantId);
  }

  async getOdps(tenantId, areaId = null) {
    return odpRepository.findByTenantId(tenantId, areaId);
  }

  async getOdpById(tenantId, id) {
    const odp = await odpRepository.findByIdAndTenantId(id, tenantId);
    if (!odp) {
      throw new NotFoundError('ODP tidak ditemukan');
    }
    return odp;
  }

  async createOdp(tenantId, data) {
    await this.getAreaById(tenantId, data.area_id);
    const existing = await odpRepository.findByCodeAndTenantId(data.code, tenantId);
    if (existing) {
      throw new ConflictError(`ODP dengan kode ${data.code} sudah terdaftar`);
    }
    return odpRepository.create(tenantId, data);
  }

  async updateOdp(tenantId, id, data) {
    await this.getOdpById(tenantId, id);
    await this.getAreaById(tenantId, data.area_id);
    const existing = await odpRepository.findByCodeAndTenantId(data.code, tenantId);
    if (existing && existing.id !== Number(id)) {
      throw new ConflictError(`ODP dengan kode ${data.code} sudah digunakan`);
    }
    return odpRepository.update(id, tenantId, data);
  }

  async deleteOdp(tenantId, id) {
    await this.getOdpById(tenantId, id);
    const isUsed = await odpRepository.isUsed(id, tenantId);
    if (isUsed) {
      throw new ConflictError('ODP tidak dapat dihapus karena masih digunakan oleh data tiket atau pelanggan');
    }
    return odpRepository.delete(id, tenantId);
  }

  async getIssueTypes(tenantId) {
    return issueTypeRepository.findByTenantId(tenantId);
  }

  async getIssueTypeById(tenantId, id) {
    const issueType = await issueTypeRepository.findByIdAndTenantId(id, tenantId);
    if (!issueType) {
      throw new NotFoundError('Jenis gangguan tidak ditemukan');
    }
    return issueType;
  }

  async createIssueType(tenantId, data) {
    return issueTypeRepository.create(tenantId, data);
  }

  async updateIssueType(tenantId, id, data) {
    await this.getIssueTypeById(tenantId, id);
    return issueTypeRepository.update(id, tenantId, data);
  }

  async deleteIssueType(tenantId, id) {
    await this.getIssueTypeById(tenantId, id);
    const isUsed = await issueTypeRepository.isUsed(id, tenantId);
    if (isUsed) {
      throw new ConflictError('Jenis gangguan tidak dapat dihapus karena masih digunakan oleh data tiket');
    }
    return issueTypeRepository.delete(id, tenantId);
  }

  async getPriorities(tenantId) {
    return priorityRepository.findByTenantId(tenantId);
  }

  async getPriorityById(tenantId, id) {
    const priority = await priorityRepository.findByIdAndTenantId(id, tenantId);
    if (!priority) {
      throw new NotFoundError('Prioritas tidak ditemukan');
    }
    return priority;
  }

  async createPriority(tenantId, data) {
    return priorityRepository.create(tenantId, data);
  }

  async updatePriority(tenantId, id, data) {
    await this.getPriorityById(tenantId, id);
    return priorityRepository.update(id, tenantId, data);
  }

  async deletePriority(tenantId, id) {
    await this.getPriorityById(tenantId, id);
    const isUsed = await priorityRepository.isUsed(id, tenantId);
    if (isUsed) {
      throw new ConflictError('Prioritas tidak dapat dihapus karena masih digunakan oleh data tiket');
    }
    return priorityRepository.delete(id, tenantId);
  }

  async getCustomers(tenantId, { search, page, limit }) {
    return customerRepository.findByTenantId(tenantId, { search, page, limit });
  }

  async getCustomerById(tenantId, id) {
    const customer = await customerRepository.findByIdAndTenantId(id, tenantId);
    if (!customer) {
      throw new NotFoundError('Pelanggan tidak ditemukan');
    }
    return customer;
  }

  async createCustomer(tenantId, data) {
    // Validasi isolasi tenant untuk area_id & odp_id jika disediakan
    if (data.area_id) {
      await this.getAreaById(tenantId, data.area_id);
    }
    if (data.odp_id) {
      const odp = await odpRepository.findByIdAndTenantId(data.odp_id, tenantId);
      if (!odp) {
        throw new NotFoundError('ODP tidak ditemukan');
      }
      if (data.area_id && odp.area_id !== data.area_id) {
        throw new ConflictError('ODP tidak berada di dalam area yang dipilih');
      }
    }
    return customerRepository.create(tenantId, data);
  }

  async updateCustomer(tenantId, id, data) {
    await this.getCustomerById(tenantId, id);
    if (data.area_id) {
      await this.getAreaById(tenantId, data.area_id);
    }
    if (data.odp_id) {
      const odp = await odpRepository.findByIdAndTenantId(data.odp_id, tenantId);
      if (!odp) {
        throw new NotFoundError('ODP tidak ditemukan');
      }
      if (data.area_id && odp.area_id !== data.area_id) {
        throw new ConflictError('ODP tidak berada di dalam area yang dipilih');
      }
    }
    return customerRepository.update(id, tenantId, data);
  }

  async deleteCustomer(tenantId, id) {
    await this.getCustomerById(tenantId, id);
    const isUsed = await customerRepository.isUsed(id, tenantId);
    if (isUsed) {
      throw new ConflictError('Pelanggan tidak dapat dihapus karena masih digunakan oleh data tiket gangguan');
    }
    return customerRepository.delete(id, tenantId);
  }

  async getActiveVendors(tenantId) {
    return vendorRepository.findActiveByTenantId(tenantId);
  }
}

export default new MasterService();
