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

  async getIssueTypes(tenantId) {
    return issueTypeRepository.findByTenantId(tenantId);
  }

  async getPriorities(tenantId) {
    return priorityRepository.findByTenantId(tenantId);
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
