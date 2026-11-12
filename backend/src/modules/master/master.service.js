import areaRepository from './areas.repository.js';
import odpRepository from './odps.repository.js';
import issueTypeRepository from './issue_types.repository.js';
import priorityRepository from './priorities.repository.js';
import customerRepository from './customers.repository.js';
import vendorRepository from './vendors.repository.js';

export class MasterService {
  async getAreas(tenantId) {
    return areaRepository.findByTenantId(tenantId);
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

  async getActiveVendors(tenantId) {
    return vendorRepository.findActiveByTenantId(tenantId);
  }
}

export default new MasterService();
