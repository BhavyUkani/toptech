import { Injectable, OnApplicationBootstrap } from '@nestjs/common';
import { EmployeeService } from './employee/employee.service';
import { EnquiryService } from './enquiry/enquiry.service';
import { CategoryService } from './category/category.service';
import { ProductService } from './product/product.service';
import { ServiceService } from './service/service.service';

@Injectable()
export class AppService implements OnApplicationBootstrap {
  constructor(
    private readonly employeeService: EmployeeService,
    private readonly enquiryService: EnquiryService,
    private readonly categoryService: CategoryService,
    private readonly productService: ProductService,
    private readonly serviceService: ServiceService,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  async onApplicationBootstrap() {
    try {
      // Check if the demo user already exists
      const existing = await this.employeeService.findByIdentifier('coder.bhavy');
      if (!existing) {
        await this.employeeService.create({
          name: 'Bhavy Ukani',
          email: 'bhavy@gmail.com',
          password: 'admin123',
          username: 'coder.bhavy',
          number: '1234567890',
          role: 'Admin',
        } as any);
        console.log('--------------------------------------------------');
        console.log('SUCCESS: Seeded demo user:');
        console.log('Name:     Bhavy Ukani');
        console.log('Username: coder.bhavy');
        console.log('Email:    bhavy@gmail.com');
        console.log('Password: admin123');
        console.log('Mobile:   1234567890');
        console.log('--------------------------------------------------');
      }

      // Check if categories are empty
      const currentCategories = await this.categoryService.findAll();
      if (currentCategories.length === 0) {
        const defaultCats = [
          'Development',
          'Infrastructure',
          'Cybersecurity',
          'Cloud',
          'Consulting',
        ];
        for (const cat of defaultCats) {
          await this.categoryService.create(cat);
        }
        console.log('SUCCESS: Seeded default categories.');
      }

      // Check if services are empty
      const currentServices = await this.serviceService.findAll();
      if (currentServices.length === 0) {
        const defaultServices = [
          'Web App Development',
          'Cloud Infrastructure Setup',
          'Mobile App UI Overhaul',
          'Cybersecurity Audit',
          'CCTV Installation',
          'CCTV Camera Maintenance',
        ];
        for (const s of defaultServices) {
          await this.serviceService.create(s);
        }
        console.log('SUCCESS: Seeded default services.');
      }

      // Check if products are empty
      const currentProducts = await this.productService.findAll();
      if (currentProducts.length === 0) {
        const defaultProds = [
          {
            name: 'Web App Dev Standard',
            code: 'WAD-01',
            lsp: '₹50,000',
            hsp: '₹75,000',
            category: 'Development',
          },
          {
            name: 'Web App Dev Enterprise',
            code: 'WAD-02',
            lsp: '₹1,50,000',
            hsp: '₹2,50,000',
            category: 'Development',
          },
          {
            name: 'Cloud VPS Support standard',
            code: 'VPS-01',
            lsp: '₹12,000/mo',
            hsp: '₹25,000/mo',
            category: 'Infrastructure',
          },
          {
            name: 'Dedicated Server Hosting',
            code: 'SRV-02',
            lsp: '₹30,000/mo',
            hsp: '₹60,000/mo',
            category: 'Infrastructure',
          },
          {
            name: 'Security Penetration Testing',
            code: 'SEC-01',
            lsp: '₹80,000',
            hsp: '₹1,50,000',
            category: 'Cybersecurity',
          },
          {
            name: 'Database Backup Cloud Sync',
            code: 'CLD-01',
            lsp: '₹6,000/mo',
            hsp: '₹15,000/mo',
            category: 'Cloud',
          },
          {
            name: 'IT Architecture Consulting',
            code: 'CNS-01',
            lsp: '₹20,000/day',
            hsp: '₹45,000/day',
            category: 'Consulting',
          },
        ];
        for (const prod of defaultProds) {
          await this.productService.create(prod);
        }
        console.log('SUCCESS: Seeded default products.');
      }

      // Check if enquiries are empty
      const currentEnquiries = await this.enquiryService.findAll();
      if (currentEnquiries.length === 0) {
        let seededEmpId = 1;
        try {
          const emp = await this.employeeService.findByIdentifier('coder.bhavy');
          if (emp) seededEmpId = emp.id;
        } catch (err) {}

        await this.enquiryService.create({
          client: 'Bhavy Ukani',
          number: '9876543210',
          product: 'Web App Development',
          assignedToId: seededEmpId,
          assignedById: seededEmpId,
          date: '14 July 2026',
          status: 'New',
        });
        await this.enquiryService.create({
          client: 'Acme Corporation',
          number: '1234567890',
          product: 'Cloud Infrastructure Setup',
          assignedToId: seededEmpId,
          assignedById: seededEmpId,
          date: '12 July 2026',
          status: 'Pending',
        });
        await this.enquiryService.create({
          client: 'Nexus Solutions',
          number: '8765432109',
          product: 'Mobile App UI Overhaul',
          assignedToId: seededEmpId,
          assignedById: seededEmpId,
          date: '10 July 2026',
          status: 'Completed',
        });
        await this.enquiryService.create({
          client: 'Globex Industries',
          number: '7654321098',
          product: 'Cybersecurity Audit',
          assignedToId: seededEmpId,
          assignedById: seededEmpId,
          date: '08 July 2026',
          status: 'Follow-up',
        });
        console.log('SUCCESS: Seeded 4 default enquiries.');
      }
    } catch (error) {
      console.warn('Could not seed database records:', error.message);
    }
  }
}
