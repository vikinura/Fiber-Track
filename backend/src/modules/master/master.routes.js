import { Router } from 'express';
import masterController from './master.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';
import { validate } from '../../middlewares/validate.js';
import {
  createAreaSchema,
  updateAreaSchema,
  deleteAreaSchema,
} from './areas.schema.js';
import {
  createCustomerSchema,
  updateCustomerSchema,
  deleteCustomerSchema,
} from './customers.schema.js';
import {
  createOdpSchema,
  updateOdpSchema,
  deleteOdpSchema,
  createIssueTypeSchema,
  updateIssueTypeSchema,
  deleteIssueTypeSchema,
  createPrioritySchema,
  updatePrioritySchema,
  deletePrioritySchema,
} from './master_extra.schema.js';

const router = Router();

// Endpoint master hanya untuk role tenant_admin
router.use(auth);
router.use(requireRole('tenant_admin'));

router.get('/areas', masterController.getAreas);
router.post('/areas', validate(createAreaSchema), masterController.createArea);
router.put('/areas/:id', validate(updateAreaSchema), masterController.updateArea);
router.delete('/areas/:id', validate(deleteAreaSchema), masterController.deleteArea);

router.get('/odps', masterController.getOdps);
router.post('/odps', validate(createOdpSchema), masterController.createOdp);
router.put('/odps/:id', validate(updateOdpSchema), masterController.updateOdp);
router.delete('/odps/:id', validate(deleteOdpSchema), masterController.deleteOdp);

router.get('/issue-types', masterController.getIssueTypes);
router.post('/issue-types', validate(createIssueTypeSchema), masterController.createIssueType);
router.put('/issue-types/:id', validate(updateIssueTypeSchema), masterController.updateIssueType);
router.delete('/issue-types/:id', validate(deleteIssueTypeSchema), masterController.deleteIssueType);

router.get('/priorities', masterController.getPriorities);
router.post('/priorities', validate(createPrioritySchema), masterController.createPriority);
router.put('/priorities/:id', validate(updatePrioritySchema), masterController.updatePriority);
router.delete('/priorities/:id', validate(deletePrioritySchema), masterController.deletePriority);
router.get('/customers', masterController.getCustomers);
router.post('/customers', validate(createCustomerSchema), masterController.createCustomer);
router.put('/customers/:id', validate(updateCustomerSchema), masterController.updateCustomer);
router.delete('/customers/:id', validate(deleteCustomerSchema), masterController.deleteCustomer);

router.get('/vendors', masterController.getVendors);

export default router;
